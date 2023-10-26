extends RigidBody2D

@export var speed = 200
@onready var screen_size = get_viewport_rect().size

func _ready():
	gravity_scale = 0.2
	var forward_dir = Vector2.from_angle(rotation).normalized()
	linear_velocity = forward_dir * speed

func _physics_process(delta):
	rotation = linear_velocity.angle()
	pass

func _on_visible_on_screen_notifier_2d_screen_exited():
	print("QUEUE FREE")
	queue_free()
