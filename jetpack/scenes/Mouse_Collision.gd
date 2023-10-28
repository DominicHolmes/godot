extends Area2D

@onready var screen_size = get_viewport_rect().size

signal mouse_collision_area_entered
signal mouse_collision_area_exited

var _collide_list = []

const COLLIDING_COLOR = Color("crimson", 0.1)
const NOT_COLLIDING_COLOR = Color("blue", 0.1)

func _ready():
	set_as_top_level(true)

func _process(delta):
	var debug_color = COLLIDING_COLOR if is_colliding() else NOT_COLLIDING_COLOR
	$CollisionShape2D.debug_color = debug_color

func _input(event):
	if event is InputEventMouseMotion:
		position = event.position
	
func _on_body_entered(body):
	_collide_list.append(body.get_instance_id())
	_collide_list.sort()
	
	mouse_collision_area_entered.emit()

func _on_body_exited(body):
	var existing_index = _collide_list.bsearch(body.get_instance_id())
	if existing_index != -1:
		_collide_list.remove_at(existing_index)
		
	if !is_colliding():
		mouse_collision_area_exited.emit()

func is_colliding():
	return not _collide_list.is_empty()
