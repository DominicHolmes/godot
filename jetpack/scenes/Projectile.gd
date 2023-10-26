extends RigidBody2D

@export var speed = 200
@onready var screen_size = get_viewport_rect().size

func _ready():
	gravity_scale = 0

func _physics_process(delta):
	var forward_dir = Vector2.from_angle(rotation).normalized()
	linear_velocity = forward_dir * speed

func _process(delta):
	# Wrap x position
	position.x = wrapf(position.x, 0, screen_size.x)

func _on_visible_on_screen_notifier_2d_screen_exited():
	print("QUEUE FREE")
	queue_free()
