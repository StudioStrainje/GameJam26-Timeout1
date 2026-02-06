extends Control

@onready var btn1: Button = %Level1
@onready var btn2: Button = %Level2
@onready var btn3: Button = %Level3
@onready var btn4: Button = %Level4
@onready var btn5: Button = %Level5

func load_score() -> int:
	if FileAccess.file_exists("user://score.int"):
		var file = FileAccess.open("user://score.int", FileAccess.READ)
		var value = file.get_var()
		file.close()
		return value
	return 1

var high_score: int = load_score()
var btns: Array = []

func _ready() -> void:
	btns = [btn1, btn2, btn3, btn4, btn5]
	_update_buttons()

func _update_buttons() -> void:
	for i in range(0, len(btns)):
		var level_number := i + 1
		var is_locked := level_number > high_score
		btns[i].disabled = is_locked
		if is_locked:
			btns[i].add_theme_color_override("font_color", Color(0.209, 0.209, 0.209, 1.0))
		else:
			btns[i].add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))


func _change_level(target_level: int) -> void:
	var tree := get_tree()
	if not tree:
		return
	tree.set_meta("selected_level", target_level)
	SceneTransition.change_scene_with_fade("res://scenes/game.tscn")


func _on_level_1_pressed() -> void:
	_change_level(1)


func _on_level_2_pressed() -> void:
	_change_level(2)


func _on_level_3_pressed() -> void:
	_change_level(3)


func _on_level_4_pressed() -> void:
	_change_level(4)


func _on_level_5_pressed() -> void:
	_change_level(5)


func _on_back_pressed() -> void:
	SceneTransition.change_scene_with_fade("res://scenes/mainmenu.tscn")

