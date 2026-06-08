extends CharacterBody3D
class_name Player

@export_range(1., 25., .1) var speed : float = 10.
@export_range(0., 10., .1) var gravity : float = 1.5
@export_range(0., 1., .0001) var drag_constant : float = 0.00
@export_range(1., 60., 1.) var rotation_speed : float = 30.
@export var raycast_area : Area3D
@export var play_area_bounds : Vector2

var pos_target : Vector2
var position_tolerance := 0.01
var calc_velocity : Vector3

func _ready() -> void:
	Global.player = self
	raycast_area.input_event.connect(process_mouse_input)

func process_mouse_input(_camera, event : InputEvent, event_position : Vector3, _normal, _shape_idx) -> void:
	if event is InputEventMouseMotion:
		event_position = raycast_area.to_local(event_position)
		update_target_position(Vector2(event_position.x, event_position.y))

func update_target_position(pos : Vector2) -> void:
	var max_height = position.y + speed
	var ceiling_bounds = Vector2(play_area_bounds.x, min(play_area_bounds.y,max_height))
	pos_target = pos.clamp(-play_area_bounds, ceiling_bounds)
	var pos_diff = pos_target - Vector2(position.x, position.y)
	if pos_diff.length() > speed:
		pos_target = Vector2(position.x, position.y) + pos_diff.normalized() * 5

func _physics_process(delta: float) -> void:
	# Lerp position and rotation towards target
	calc_velocity = -transform.basis.z.normalized()*speed;
	var drop = 0.0
	if speed <= 2:
		drop = 2 - speed
	#var collision = move_and_collide(delta*Vector3(calc_velocity.x, calc_velocity.y - drop, calc_velocity.z),true)
	#if collision:
		#print(collision.get_normal())
	speed = max(1,speed - delta*gravity * calc_velocity.y - drag_constant * speed)
	rotation = lerp(
		rotation,
		transform.looking_at(Vector3(pos_target.x, pos_target.y, -5)).basis.get_euler(),
		delta*rotation_speed)
	position += delta*Vector3(calc_velocity.x, calc_velocity.y - drop, 0)
	
