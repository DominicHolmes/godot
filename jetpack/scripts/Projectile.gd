extends RigidBody2D
class_name Projectile

enum ProjectileType { FIRE, WATER, EARTH, AIR }

@export var speed = 500
@onready var screen_size = get_viewport_rect().size
@export var initial_linear_velocity: Vector2
@export var caster_id = -1
@export var explosion_position: Vector2
@export var projectile_type = ProjectileType.WATER

func _enter_tree():
	set_multiplayer_authority(get_parent().get_multiplayer_authority())
	
# Called with the charge_duration, in seconds
func setup_initial_velocity(charge_duration):
	var forward_dir = Vector2.from_angle(rotation).normalized()
	var clamped_duration = clampf(charge_duration, 0.2, 1.3)
	initial_linear_velocity = forward_dir * speed * clamped_duration
	
func _ready():
	linear_velocity = initial_linear_velocity
	_play_travel_animation()
	_adjust_trail_color()

func _process(_delta):
	if explosion_position and not _is_playing_explode_animation():
		position = explosion_position
		linear_velocity = Vector2.ZERO
		_play_explode_animation()
		$ProjectileAnimation.connect("animation_finished", 
			explosion_animation_finished)

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
	
func _adjust_trail_color():
	if projectile_type == ProjectileType.FIRE:
		$Trail.modulate = Color("d1773a", 0.7)
	elif projectile_type == ProjectileType.WATER:
		$Trail.modulate = Color("7ccae1", 0.7)
	elif projectile_type == ProjectileType.AIR:
		$Trail.modulate = Color("ffffff", 0.5)
	elif projectile_type == ProjectileType.EARTH:
		$Trail.modulate = Color("875940", 0.7)
	
func _play_travel_animation():
	if projectile_type == ProjectileType.FIRE:
		$ProjectileAnimation.play("travel_fire")
	elif projectile_type == ProjectileType.WATER:
		$ProjectileAnimation.play("travel_water")
	elif projectile_type == ProjectileType.AIR:
		$ProjectileAnimation.play("travel_air")
	elif projectile_type == ProjectileType.EARTH:
		$ProjectileAnimation.play("travel_earth")

func _play_explode_animation():
	if projectile_type == ProjectileType.FIRE:
		$ProjectileAnimation.play("explode_fire")
	elif projectile_type == ProjectileType.WATER:
		$ProjectileAnimation.play("explode_water")
	elif projectile_type == ProjectileType.AIR:
		$ProjectileAnimation.play("explode_air")
	elif projectile_type == ProjectileType.EARTH:
		$ProjectileAnimation.play("explode_earth")

func _is_playing_explode_animation():
	return $ProjectileAnimation.animation == "explode_fire" or \
		$ProjectileAnimation.animation == "explode_water" or \
		$ProjectileAnimation.animation == "explode_air" or \
		$ProjectileAnimation.animation == "explode_earth"
