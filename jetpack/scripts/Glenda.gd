extends CharacterBody2D

@export var speed = 300.0
@export var jump_speed = 600.0
@export var grav = 600.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if !is_on_floor():
		velocity.y += (grav * delta)
	
	# Horizontal movement
	var h_input_direction = Input.get_axis("move_left", "move_right")
	velocity.x = speed * h_input_direction
	
	if Input.is_action_just_pressed("move_jump"):
		velocity.y -= jump_speed
	
	velocity.y = clamp(velocity.y, -600, 600)
	
	move_and_slide()
