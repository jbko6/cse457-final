extends Node3D
class_name CityGenerator

@export var city_block_size := 6
@export var city_blocks : Array[PackedScene] 
@export var buildings : Array[PackedScene]
@export var building_materials : Array[Material]
# @export var obstacles : Array[PackedScene]
@export var starting_speed := 1.
@export var speed_increase_rate := 0.2
@export var perspective_reference : Node3D

var active_blocks : Array[CityBlock]
var current_path : Path3D
var path_distance := 0.
var speed := 0.
var prev_position: Vector3
var rotation_speed_mult = 1.

const BuildingLabel := "Building"
# const ObstacleLabel := "Obstacle"

func _ready() -> void:
	Global.city = self

	# instantiate initial blocks
	add_block()
	current_path = add_block().player_path
	add_block()
	add_block()
	add_block()

	speed = starting_speed

func _process(delta: float) -> void:
	if Global.player.alive:
		path_distance += speed * rotation_speed_mult * delta
	if (path_distance > current_path.curve.get_baked_length()):
		pop_block()
		add_block()
		path_distance = 0

	var top_block := active_blocks[1]

	var path_transform := current_path.curve.sample_baked_with_rotation(path_distance).rotated(Vector3.UP, 	top_block.rotation.y) 

	prev_position = Global.player.global_position
	var block_prev_position = top_block.global_position
	top_block.position = path_transform.origin.rotated(Vector3.UP, PI) * Vector3(1, -1, 1) * city_block_size
	
	if perspective_reference.rotation != path_transform.basis.get_euler():
		perspective_reference.rotation = path_transform.basis.get_euler()
		var scale_velocity = (Global.player.global_position - prev_position - (top_block.global_position - block_prev_position)).length()/ (Global.player.calc_velocity.z*delta)
		rotation_speed_mult /= -1*scale_velocity
		rotation_speed_mult = clampf(rotation_speed_mult,0,2)
	else:
		rotation_speed_mult = 1
	speed = -1.0/city_block_size*Global.player.calc_velocity.z

func add_block() -> CityBlock:
	var new_block : CityBlock = city_blocks.pick_random().instantiate()
	if active_blocks.size() == 1:
		var top_block := active_blocks[0]
		add_child(new_block)
		top_block.reparent(new_block)
		top_block.scale = Vector3.ONE
		new_block.scale = Vector3.ONE * city_block_size
	elif active_blocks.size() > 0:
		var last_block_index := active_blocks.size() - 1
		active_blocks[last_block_index].add_child(new_block)
		new_block.position = active_blocks[last_block_index].next_block_offset
		new_block.rotate_y(deg_to_rad(active_blocks[last_block_index].next_rotation_offset))
	else:
		new_block.scale = Vector3.ONE * city_block_size
		add_child(new_block)
	active_blocks.append(new_block)
	populate_buildings(new_block)
	# populate_obstacles(new_block)
	return new_block

func pop_block() -> CityBlock:
	if active_blocks.size() > 1:
		var new_head : CityBlock = active_blocks[2]
		var new_follower : CityBlock = active_blocks[1]
		new_head.reparent(self)
		new_follower.reparent(new_head)
		new_follower.scale = Vector3.ONE
		current_path = new_head.player_path
		active_blocks.pop_front().queue_free()
		new_head.scale = Vector3.ONE * city_block_size

		activate_obstacles(new_head)
		if active_blocks.size() >= 3:
			ready_obstacles(active_blocks[2])

		return new_head
	elif active_blocks.size() == 1:
		var new_head = active_blocks.pop_front()
		activate_obstacles(new_head)
		return new_head
	return null

func populate_buildings(block : CityBlock) -> CityBlock:
	for child in block.get_children():
		if child is Label3D:
			if child.text == BuildingLabel:
				var new_building : Node3D = buildings.pick_random().instantiate()
				new_building.transform = child.transform
				# if new_building is MeshInstance3D:
				# 	new_building.mesh.material = building_materials.pick_random()
				var building_name := child.name
				child.queue_free()
				new_building.name = building_name
				block.add_child(new_building)
	return block

# func populate_obstacles(block : CityBlock) -> CityBlock:
# 	for child in block.get_children():
# 		if child is Label3D:
# 			if child.text == ObstacleLabel:
# 				var new_obstacle : Obstacle = obstacles.pick_random().instantiate()
# 				new_obstacle.transform = child.transform
# 				var obstacle_name := child.name
# 				child.queue_free()
# 				new_obstacle.name = obstacle_name
# 				block.add_child(new_obstacle)
# 	return block

func ready_obstacles(block : CityBlock) -> void:
	for child in block.get_children():
		if child is Obstacle:
			child._ready_obstacle()

func activate_obstacles(block : CityBlock) -> void:
	for child in block.get_children():
		if child is Obstacle:
			child._activate_obstacle()
