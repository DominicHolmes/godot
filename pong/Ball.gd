extends RigidBody2D

class_name Ball

const START_SPEED = 400.0

var screen_size
var ball_radius = 8.0

func _ready():
	hide()

func serve(vel):
	screen_size = get_viewport_rect().size
	position = Vector2(screen_size.x / 2, screen_size.y / 2)
	linear_velocity = vel.normalized() * START_SPEED
	show()
