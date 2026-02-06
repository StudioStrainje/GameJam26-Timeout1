extends Control

@onready var btn1: Button = $"Buttons/Button"
@onready var btn2: Button = $"Buttons/Button2"
@onready var btn3: Button = $"Buttons/Button3"
@onready var btn4: Button = $"Buttons/Button4"
@onready var btn5: Button = $"Buttons/Button5"

@onready var sprite1: AnimatedSprite2D = $"Buttons/Button/Level1"
@onready var sprite2: AnimatedSprite2D = $"Buttons/Button2/Level2"
@onready var sprite3: AnimatedSprite2D = $"Buttons/Button3/Level3"
@onready var sprite4: AnimatedSprite2D = $"Buttons/Button4/Level4"
@onready var sprite5: AnimatedSprite2D = $"Buttons/Button5/Level5"

func load_score() -> int:
	if FileAccess.file_exists("user://score.int"):
		var file = FileAccess.open("user://score.int", FileAccess.READ)
		var value = file.get_var()
		file.close()
		return value
	return 1

var high_score: int = load_score()
var btns: Array = []
var sprites: Array = []

func _ready() -> void:
	btns = [btn1, btn2, btn3, btn4, btn5]
	sprites = [sprite1, sprite2, sprite3, sprite4, sprite5]
	for i in range(0, len(btns)):
		btns[i].pressed.connect(func() -> void:
			_change_level(i + 1)
		)
		btns[i].mouse_entered.connect(func() -> void:
			_set_hover(i, true)
		)
		btns[i].mouse_exited.connect(func() -> void:
			_set_hover(i, false)
		)
	_update_buttons()

func _update_buttons() -> void:
	for i in range(0, len(btns)):
		var level_number := i + 1
		var is_locked := level_number > high_score
		btns[i].disabled = is_locked
		if is_locked:
			sprites[i].play("locked")
		else:
			sprites[i].play("default")


func _set_hover(index: int, is_hovered: bool) -> void:
	var level_number := index + 1
	var is_locked := level_number > high_score
	if is_locked:
		sprites[index].play("locked")
		return
	if is_hovered:
		sprites[index].play("selected")
	else:
		sprites[index].play("default")


func _change_level(target_level: int) -> void:
	var tree := get_tree()
	if not tree:
		return
	tree.set_meta("selected_level", target_level)
	SceneTransition.change_scene_with_fade("res://scenes/game.tscn")


func _on_back_pressed() -> void:
	SceneTransition.change_scene_with_fade("res://scenes/mainmenu.tscn")
