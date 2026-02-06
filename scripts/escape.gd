extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var background: Sprite2D = %Background
@onready var overlay: ColorRect = %Overlay
@onready var menu: Control = %VBoxContainer

var is_closing := false
var pending_scene_path := ""

func _ready() -> void:
	background.modulate.a = 0.0
	overlay.color.a = 0.0
	menu.modulate.a = 0.0
	animation_player.play("fade_in")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		get_viewport().set_input_as_handled()
		close_menu()

func close_menu() -> void:
	_start_close("")

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

func _on_main_menu_pressed() -> void:
	_start_close("res://scenes/mainmenu.tscn")


func _on_levels_pressed() -> void:
	_start_close("res://scenes/level_selector.tscn")

func _on_resume_pressed() -> void:
	close_menu()
