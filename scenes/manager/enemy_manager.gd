extends Node

var spawn_radius: float

@export var basic_enemy_scene: PackedScene
@export var wizard_enemy_scene: PackedScene
@export var arena_time_manager: Node

@onready var timer = $Timer

var base_spawn_time: float
var enemy_table = WeightedTable.new()


func _ready() -> void:
	enemy_table.add_item(basic_enemy_scene, 10)
	
	base_spawn_time = timer.wait_time
	var viewport_width = ProjectSettings.get_setting("display/window/size/viewport_width")
	var viewport_height = ProjectSettings.get_setting("display/window/size/viewport_height")
	
	if viewport_width > viewport_height:
		spawn_radius = viewport_width
	else:
		spawn_radius = viewport_height
	spawn_radius += 40
	
	arena_time_manager.arena_difficulty_increased.connect(on_arena_difficulty_increased)
	
	timer.timeout.connect(on_timer_timeout)


func get_spawn_position() -> Vector2:
	var player: Node2D = get_tree().get_first_node_in_group("player")
	if player == null:
		return Vector2.ZERO
	
	var spawn_position = Vector2.ZERO
	var random_direction: Vector2 = Vector2.RIGHT.rotated(randf_range(0, TAU))
	for i in 4:
		
		spawn_position = player.global_position + (random_direction * spawn_radius)
		
		var query_parameters = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position, 1)
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
		
		if result.is_empty():
			break
		else:
			random_direction = random_direction.rotated(deg_to_rad(90))
	
	return spawn_position

func on_timer_timeout():
	timer.start()
	
	var player: Node2D = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	
	var enemy_scene = enemy_table.pick_item()
	var enemy: Node2D = enemy_scene.instantiate()
	
	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	if entities_layer == null:
		return
	
	entities_layer.add_child(enemy)
	enemy.global_position = get_spawn_position()


func on_arena_difficulty_increased(arena_difficulty: int):
	var time_off = (.1 / 12) * arena_difficulty
	time_off = min(time_off, .7)
	timer.wait_time = base_spawn_time - time_off
	
	if arena_difficulty == 6:
		enemy_table.add_item(wizard_enemy_scene, 20)
