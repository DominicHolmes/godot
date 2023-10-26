extends CharacterBody2D

@export var speed = 100.0
@export var jump_speed = 100.0
@export var grav = 200.0

@onready var anim = $AnimatedSprite2D
@onready var screen_size = get_viewport_rect().size

var fireball_scene = preload("res://scenes/Projectile.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if !is_on_floor():
		velocity.y += (grav * delta)
		anim.play("run") # falling
	
	if Input.is_action_just_pressed("move_jump"):
		velocity.y -= jump_speed
		anim.play("charge") # boosting
	
	# Horizontal movement
	var h_input_direction = Input.get_axis("move_left", "move_right")
	velocity.x = speed * h_input_direction * (1.0 if is_on_floor else 0.2)
	if h_input_direction != 0:
		anim.play("run")
		anim.flip_h = h_input_direction == -1
	
	if is_on_floor() && velocity.x == 0 && velocity.y == 0:
		anim.play("idle")
	
	velocity.y = clamp(velocity.y, -200, 200)
	
	# If attack animation is playing, offset x by 32px
	
	move_and_slide()

func _process(delta):
	if Input.is_action_just_pressed("shoot"):
		var mouse_position = get_viewport().get_mouse_position()
		print("mouse_pos", mouse_position)
		print("global_position_player", global_position)
		fire_projectile(mouse_position)
	
	# Wrap character position
	position.x = wrapf(position.x, 0, screen_size.x)
	position.y = wrapf(position.y, 0, screen_size.y)
		
func fire_projectile(mouse_position):
	var fireball = fireball_scene.instantiate()
	get_parent().add_child(fireball)
	# TODO: instead originate from Marker2D rotating around player
	fireball.global_position = global_position
	var mouse_direction = (mouse_position - fireball.global_position).normalized()
	print("mouse_dir", mouse_direction)
	fireball.rotation = atan2(mouse_direction.y, mouse_direction.x)
