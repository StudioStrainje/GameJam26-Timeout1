extends Control

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_credits_pressed() -> void:
	SceneTransition.change_scene_with_fade("res://scenes/credits.tscn")

func _on_start_pressed() -> void:
	SceneTransition.change_scene_with_fade("res://scenes/level_selector.tscn")


func _on_controls_pressed() -> void:
	SceneTransition.change_scene_with_fade("res://scenes/controls.tscn")
