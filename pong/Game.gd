extends Node

var game_active = false
var p1_score = 0
var p2_score = 0
var bounce_counter = 0
var last_point_p1 = false

@export var ball_scene: PackedScene

var ball

# Called when the node enters the scene tree for the first time.
func _ready():
	$Paddle1.start(Vector2(100, 300))
	$Paddle2.start(Vector2(1000, 300))
	
func _process(_delta):
	if Input.is_action_pressed("serve") && !game_active:
		$BounceLabel.text = ""
		serve()
	
func reset_game():
	game_active = false
	bounce_counter = 0
	$BounceLabel.text = "P1 wins" if last_point_p1 else "P2 wins"
	$ScoreLabel1.text = "Score: " + str(p1_score)
	$ScoreLabel2.text = "Score: " + str(p2_score)
	
	ball.hide()
	ball.queue_free()
	
func serve():
	if game_active:
		return
	game_active = true
	
	ball = ball_scene.instantiate()
	add_child(ball)
	ball.serve(get_random_serve_vector())
	
func get_random_serve_vector():
	return Vector2(
		1.0 if last_point_p1 else -1.0,
		randf_range(-0.2, 0.2),
	)

func _on_endzone_1_ball_detected():
	p2_score += 1
	last_point_p1 = false
	reset_game()

func _on_endzone_2_ball_detected():
	p1_score += 1
	last_point_p1 = true
	reset_game()
	
func _on_ball_hit_paddle():
	bounce_counter += 1
	$BounceLabel.text = str(bounce_counter)
