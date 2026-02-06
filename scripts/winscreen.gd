extends Control

func _on_back_to_main_menu_pressed() -> void:
	SceneTransition.change_scene_with_fade("res://scenes/mainmenu.tscn")
