extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var background: ColorRect = %ColorRect
@onready var menu: Control = %VBoxContainer

var is_closing := false
var pending_scene_path := ""

func _ready() -> void:
	background.color = Color(0, 0, 0, 0)
	menu.modulate.a = 0.0
	animation_player.play("fade_in")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		get_viewport().set_input_as_handled()
		_start_close("res://scenes/level_selector.tscn")

func _start_close(scene_path: String) -> void:
	if is_closing:
		return
	is_closing = true
	pending_scene_path = scene_path
	animation_player.animation_finished.connect(_on_fade_out_finished, Object.CONNECT_ONE_SHOT)
	animation_player.play("fade_out")

func _on_fade_out_finished(_animation_name: StringName) -> void:
	get_tree().paused = false
	if pending_scene_path != "":
		SceneTransition.change_scene_with_fade(pending_scene_path)
	queue_free()

func _on_restart_pressed() -> void:
	var game: Node = get_tree().root.get_node_or_null("Game")
	if game and game.has_method("get_level"):
		get_tree().set_meta("selected_level", game.get_level())
	_start_close("res://scenes/game.tscn")

func _on_levels_pressed() -> void:
	_start_close("res://scenes/level_selector.tscn")

func _on_main_menu_pressed() -> void:
	_start_close("res://scenes/mainmenu.tscn")
