extends Area2D

@export var is_player_1 = false

signal ball_detected

func _on_body_entered(body):
	if body is Ball:
		ball_detected.emit()
