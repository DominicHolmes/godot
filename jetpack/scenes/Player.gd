extends CharacterBody2D


const SPEED = 120.0
const JUMP_VELOCITY = -300.0
const RECOIL = 40.0

@onready var Anim = $AnimatedSprite2D
@onready var screen_size = get_viewport_rect().size

var fireball_scene = preload("res://scenes/Projectile.tscn")

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# set to 1 initially, in case the character is falling. sets to 2 once on floor
var jumps_remaining = 100
@export var aim_rotation = 0.0
@export var player_id = 0

@export var is_charging = false
@export var is_recoiling = false
var did_show_charge_sparks = false
@export var charge_duration = 0.0

func _enter_tree():
	print("In player, multi_auth: ", get_parent().get_multiplayer_authority())
	set_multiplayer_authority(get_parent().get_multiplayer_authority())

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	# add gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# refill jumps if on floor
	if is_on_floor():
		jumps_remaining = 2
		
	# handle jump input
	if Input.is_action_just_pressed("move_jump"):
		if jumps_remaining > 0:
			jumps_remaining -= 1
			velocity.y = JUMP_VELOCITY
	
	# handle x input
	var direction = Input.get_axis("move_left", "move_right")
	var is_on_floor_modifier = 1.0 if is_on_floor() else 0.8
	if direction:
		velocity.x = direction * SPEED * is_on_floor_modifier
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * is_on_floor_modifier)
	
	# add recoil
	var recoil_modifier = clampf(RECOIL * charge_duration, 0, RECOIL * 1.3) if is_recoiling else 0
	var recoil_direction = 1 if abs(rad_to_deg(aim_rotation)) >= 90 else -1
	velocity.x += (recoil_modifier * recoil_direction)

	move_and_slide()

func _input(event):
	if not is_multiplayer_authority(): return
	if event is InputEventMouseMotion:
		var mouse_direction = (event.position - global_position).normalized()
		aim_rotation = atan2(mouse_direction.y, mouse_direction.x)
	
	if event.is_action_pressed("shoot"):
		is_charging = true
		charge_duration = 0.0
	elif event.is_action_released("shoot") and not is_recoiling:
		is_charging = false
		did_show_charge_sparks = false
		fire_projectile()

func _process(delta):
	update_animation()
	update_aim_rotation()
	if not is_multiplayer_authority(): return
	wrap_position_if_off_screen()
	if is_charging:
		charge_duration += delta
		if not did_show_charge_sparks and charge_duration > 1:
			$ChargedSparks.emitting = true
			did_show_charge_sparks = true
	
func wrap_position_if_off_screen():
	position.x = wrapf(position.x, 0, screen_size.x)
	position.y = wrapf(position.y, 0, screen_size.y)
	
func update_aim_rotation():
	$AimRotation.rotation = aim_rotation
	
func update_animation():
	var face_right = abs(rad_to_deg(aim_rotation)) >= 90
	Anim.flip_h = face_right
	$ChargedSparks.position = Vector2(8.5 if face_right else -8.5, -12)
	
	if is_recoiling:
		if Anim.animation == "attack_complete_ground" or Anim.animation == "attack_complete_air":
			if !Anim.is_playing():
				is_recoiling = false
		else:
			Anim.play("attack_complete_ground" if is_on_floor() else "attack_complete_air")
	elif is_charging:
		if is_on_floor():
			if charge_duration < 1:
				Anim.play("attack_channel_ground")
			else:
				Anim.play("attack_channel_ground_loop")
		else:
			if charge_duration < 1:
				Anim.play("attack_channel_air")
			else:
				Anim.play("attack_channel_air_loop")
	else:
		if velocity.x == 0:
			if is_on_floor():
				Anim.play("idle_ground")
			else:
				Anim.play("idle_air")
		elif velocity.x != 0:
			if is_on_floor():
				Anim.play("walk_forward")
			else:
				Anim.play("fly_forward")

func fire_projectile():
	var fireball = fireball_scene.instantiate()
	print("FIRE with charge duration: ", charge_duration)
	fireball.global_position = $AimRotation/Reticle.global_position
	fireball.caster_id = multiplayer.get_unique_id()
	fireball.rotation = aim_rotation
	fireball.setup_initial_velocity(charge_duration)
	get_parent().add_child(fireball, true)
	recoil_from_firing_projectile()
	
func recoil_from_firing_projectile():
	is_recoiling = true
	var fired_right = abs(rad_to_deg(aim_rotation)) >= 90
	velocity.x += 200 if fired_right else -200

func _on_area_2d_body_entered(body):
	# Players detect and attempt to trigger all projectile collisions
	if body.caster_id != player_id:
		# Only owner of projectile will succeed in triggering collision
		body.trigger_explosion()
