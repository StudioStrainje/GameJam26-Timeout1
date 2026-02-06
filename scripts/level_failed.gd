extends Control

func _on_restart_pressed() -> void:
	var game: Node = get_tree().root.get_node_or_null("Game")
	if game and game.has_method("get_level"):
		get_tree().set_meta("selected_level", game.get_level())
	SceneTransition.change_scene_with_fade("res://scenes/game.tscn")

func _on_levels_pressed() -> void:
	SceneTransition.change_scene_with_fade("res://scenes/level_selector.tscn")

func _on_main_menu_pressed() -> void:
	SceneTransition.change_scene_with_fade("res://scenes/mainmenu.tscn")
