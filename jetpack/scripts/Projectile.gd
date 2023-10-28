extends RigidBody2D
class_name Projectile

@export var speed = 300
@onready var screen_size = get_viewport_rect().size
@export var initial_linear_velocity: Vector2
@export var caster_id = -1
@export var explosion_position: Vector2

func _enter_tree():
	set_multiplayer_authority(get_parent().get_multiplayer_authority())
	
func setup_initial_velocity():
	var forward_dir = Vector2.from_angle(rotation).normalized()
	initial_linear_velocity = forward_dir * speed
	
func _ready():
	linear_velocity = initial_linear_velocity

func _process(_delta):
	if explosion_position && $AnimatedSprite2D.animation != "fire_explode":
		position = explosion_position
		linear_velocity = Vector2.ZERO
		$AnimatedSprite2D.play("fire_explode")
		
		$AnimatedSprite2D.connect("animation_finished", explosion_animation_finished)

func _physics_process(_delta):
	if explosion_position:
		gravity_scale = 0
		linear_velocity = Vector2.ZERO
		rotation = 0
	else:
		gravity_scale = 0.2
		rotation = linear_velocity.angle()
	
func trigger_explosion():
	if not is_multiplayer_authority(): return
	explosion_position = position

func explosion_animation_finished():
	if not is_multiplayer_authority(): return
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	if not is_multiplayer_authority(): return
	# Wraparound in x direction by spawning a duplicate projectile at -x
	if position.y > 0 && position.y < screen_size.y:
		var duplicate_node = duplicate(DUPLICATE_USE_INSTANTIATION)
		duplicate_node.position.x = wrapf(position.x, 0, screen_size.x)
		duplicate_node.rotation = rotation
		duplicate_node.initial_linear_velocity = linear_velocity
		get_parent().add_child(duplicate_node, true)
	queue_free_with_delay(3)

func queue_free_with_delay(wait_time):
	var timer = Timer.new()
	timer.wait_time = wait_time
	timer.one_shot = true
	timer.connect("timeout", queue_free)
	add_child(timer)
	timer.start()
