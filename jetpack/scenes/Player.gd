extends CharacterBody2D


const SPEED = 120.0
const JUMP_VELOCITY = -300.0

@onready var Anim = $AnimatedSprite2D
@onready var screen_size = get_viewport_rect().size

var fireball_scene = preload("res://scenes/Projectile.tscn")

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# set to 1 initially, in case the character is falling. sets to 2 once on floor
var jumps_remaining = 100
@export var aim_rotation = 0.0
@export var player_id = 0

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

	move_and_slide()

func _input(event):
	if not is_multiplayer_authority(): return
	if event is InputEventMouseMotion:
		var mouse_direction = (event.position - global_position).normalized()
		aim_rotation = atan2(mouse_direction.y, mouse_direction.x)

func _process(delta):
	update_animation()
	update_aim_rotation()
	if not is_multiplayer_authority(): return
	wrap_position_if_off_screen()
	
	if Input.is_action_just_pressed("shoot"):
		var mouse_position = get_viewport().get_mouse_position()
		fire_projectile(mouse_position)
	
func wrap_position_if_off_screen():
	position.x = wrapf(position.x, 0, screen_size.x)
	position.y = wrapf(position.y, 0, screen_size.y)
	
func update_aim_rotation():
	$AimRotation.rotation = aim_rotation
	
func update_animation():
	Anim.flip_h = abs(rad_to_deg(aim_rotation)) >= 90
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

func fire_projectile(mouse_position):
	var fireball = fireball_scene.instantiate()
	fireball.global_position = $AimRotation/Reticle.global_position
	fireball.caster_id = multiplayer.get_unique_id()
	fireball.rotation = aim_rotation
	fireball.setup_initial_velocity()
	get_parent().add_child(fireball, true)


func _on_area_2d_body_entered(body):
	print("COLLISION DETECTED")
	print("Mult id ", multiplayer.get_unique_id())
	print("Player id ", player_id)
	print("Is server ", multiplayer.is_server())
	# Players detect and attempt to trigger all projectile collisions
	if body.caster_id != player_id:
		# Only owner of projectile will succeed in triggering
		print("Collision detected with caster_id of ", body.caster_id)
		print("Mult id ", multiplayer.get_unique_id())
		print("Is server ", multiplayer.is_server())
		body.trigger_explosion()
		
		
#	if not is_multiplayer_authority(): return
#	if body is Projectile:
#		# Do not detect collisions of your own projectiles
#		if body.caster_id != multiplayer.get_unique_id():
#			print("Collision detected with caster_id of ", body.caster_id)
#			print("Mult id ", multiplayer.get_unique_id())
#			body.trigger_explosion()
