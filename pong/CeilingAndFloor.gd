extends Area2D

func _on_body_entered(body):
	if body.name == "Ball" && body is RigidBody2D:
		body.linear_velocity *= Vector2(1, -1)
