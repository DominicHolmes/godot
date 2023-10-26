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

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

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
		fire_projectile.rpc(mouse_position)
	
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

@rpc("authority", "call_local")
func fire_projectile(mouse_position):
	print("FIRE PROJECTILE")
	print("is on server: ", multiplayer.is_server())
	
	var fireball = fireball_scene.instantiate()
		# TODO: instead originate from Marker2D rotating around player
	fireball.global_position = global_position
	var mouse_direction = (mouse_position - global_position).normalized()
	fireball.rotation = atan2(mouse_direction.y, mouse_direction.x)
	get_parent().add_child(fireball, true)
