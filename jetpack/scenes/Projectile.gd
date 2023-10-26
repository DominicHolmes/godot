extends RigidBody2D

@export var speed = 200
@onready var screen_size = get_viewport_rect().size

func _ready():
	gravity_scale = 0.2
	var forward_dir = Vector2.from_angle(rotation).normalized()
	linear_velocity = forward_dir * speed

func _physics_process(_delta):
	rotation = linear_velocity.angle()

func _on_visible_on_screen_notifier_2d_screen_exited():
	# Wraparound in x direction by spawning a duplicate projectile at -x
	if position.y > 0 && position.y < screen_size.y:
		var duplicate_node = duplicate(DUPLICATE_USE_INSTANTIATION)
		get_parent().add_child(duplicate_node)
		duplicate_node.position.x = wrapf(position.x, 0, screen_size.x)
		duplicate_node.rotation = rotation
		duplicate_node.linear_velocity = linear_velocity
	
	queue_free_with_delay(3)

func queue_free_with_delay(wait_time):
	var timer = Timer.new()
	timer.wait_time = wait_time
	timer.one_shot = true
	timer.connect("timeout", queue_free)
	add_child(timer)
	timer.start()
