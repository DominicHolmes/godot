extends Node2D

@export var max_length = 20
@export var thickness = 3.0

@onready var screen_size = get_viewport_rect().size

var points = []
var frame = 0

func _physics_process(_delta):
	# Runs at 60 fps, so updating each 3rd frame is equivalent to updating each
	# 1/20 of a second. This reduces size of points array.
	if frame % 3 == 0:
		points.push_front(global_position)
		if points.size() > max_length:
			points.pop_back()
	
	frame += 1
	
	# Trigger a redraw in the _draw() method
	queue_redraw()

func _draw():
	# we need at least 2 points to draw
	if points.size() < 2:
		return
		
	var antialias = false
	var c = modulate
	var s = float(points.size())
	var adjusted = PackedVector2Array()
	var colors = PackedColorArray()
	
	# Create offset points and color arrays
	for i in range(s):
		adjusted.append(points[i] - global_position)
		c.a = lerp(1.0, 0.0, i/s)
		colors.append(c)
	
	# Draw line in global space with rotation of parent cancelled out
	draw_set_transform(Vector2(0,0), -get_parent().rotation, Vector2(1,1))
	draw_polyline_colors(adjusted, colors, thickness, antialias)
		
func is_value_in_range(value, min_value, max_value):
	return value >= min_value && value <= max_value
