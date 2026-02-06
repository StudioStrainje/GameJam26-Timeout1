extends Control

@onready var label: Label = %Label

func _ready() -> void:
	var reason = get_tree().get_meta("fail_reason", "teacher")
	if reason == "time":
		label.text = "Time's up! You failed your exams!"
	else:
		label.text = "You were caught by the teacher!"

func _on_restart_pressed() -> void:
	SceneTransition.change_scene_with_fade("res://scenes/game.tscn")

func _on_levels_pressed() -> void:
	SceneTransition.change_scene_with_fade("res://scenes/level_selector.tscn")

func _on_main_menu_pressed() -> void:
	SceneTransition.change_scene_with_fade("res://scenes/mainmenu.tscn")
