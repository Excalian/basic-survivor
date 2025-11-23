extends Node

var spawn_radius: float

@export var basic_enemy_scene: PackedScene

func _ready() -> void:
	var viewport_width = ProjectSettings.get_setting("display/window/size/viewport_width")
	var viewport_height = ProjectSettings.get_setting("display/window/size/viewport_height")
	
	if viewport_width > viewport_height:
		spawn_radius = viewport_width
	else:
		spawn_radius = viewport_height
	spawn_radius += 40
	
	$Timer.timeout.connect(on_timer_timeout)


func on_timer_timeout():
	var player: Node2D = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	
	var random_direction: Vector2 = Vector2.RIGHT.rotated(randf_range(0, TAU))
	var spawn_position: Vector2 = player.global_position + (random_direction * spawn_radius)
	
	var enemy: Node2D = basic_enemy_scene.instantiate()
	get_parent().add_child(enemy)
	enemy.global_position = spawn_position
