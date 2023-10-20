extends Area2D

@export var is_player_1 = false
@export var speed = 300.0
var screen_size

var last_velocity = 0.0
var paddle_height

signal ball_hit_paddle

func start(pos):
	position = pos

func _ready():
	screen_size = get_viewport_rect().size
	paddle_height = $CollisionShape2D.shape.size.y

func _process(delta):
	var velocity = Vector2.ZERO
	if is_player_1:
		if Input.is_action_pressed("p1_move_up"):
			velocity.y -= 1
		if Input.is_action_pressed("p1_move_down"):
			velocity.y += 1
	else:
		if Input.is_action_pressed("p2_move_up"):
			velocity.y -= 1
		if Input.is_action_pressed("p2_move_down"):
			velocity.y += 1
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	last_velocity = velocity.y

func _on_body_entered(body):
	if body.name == "Ball" && body is RigidBody2D:
		var isAboveBelow = is_ball_above_below_paddle(body)
		var bounceVector = Vector2(1,-1) if isAboveBelow else Vector2(-1,1)
		body.linear_velocity *= bounceVector
		print(isAboveBelow)
		if abs(last_velocity) > 0:
			body.linear_velocity.y += (last_velocity * 0.3)
		ball_hit_paddle.emit()
		
func is_ball_above_below_paddle(ball: Ball):
	var ballTop = ball.global_position.y
	var ballBottom = ball.global_position.y + (ball.ball_radius * 2)
	
	var paddleTop = position.y
	var paddleBottom = paddleTop + paddle_height
	
	return ballBottom < paddleTop || paddleBottom < ballTop
