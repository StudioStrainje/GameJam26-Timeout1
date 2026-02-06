extends Node2D

const DISPLAY_SECONDS := 5.0

func _ready() -> void:
	await get_tree().create_timer(DISPLAY_SECONDS).timeout
	SceneTransition.change_scene_with_fade("res://scenes/game.tscn")
