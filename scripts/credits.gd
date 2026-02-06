extends Control

func _on_back_pressed() -> void:
	SceneTransition.change_scene_with_fade("res://scenes/mainmenu.tscn")
