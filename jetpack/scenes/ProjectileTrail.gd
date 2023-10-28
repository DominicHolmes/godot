extends Line2D

@export var length = 10
@onready var parent = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	# Draw at top level, so as to not draw as a "sub-drawing" of the projectile
	set_as_top_level(true)
	# Clear editor points
	clear_points()

func _physics_process(delta):
	add_point(parent.global_position)
	if points.size() > length:
		remove_point(0)

func set_fading_color(color: Color):
	var grad = Gradient.new()
	grad.colors = [Color(color, 0.0), Color(color, 0.5)]
	gradient = grad
	modulate = Color(2, 2, 2, 1)
