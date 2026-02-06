extends Control

@onready var hand: Sprite2D = $Hand
@onready var start_button: Button = $VBoxContainer/Start
@onready var controls_button: Button = $VBoxContainer/Controls
@onready var credits_button: Button = $VBoxContainer/Credits
@onready var quit_button: Button = $VBoxContainer/Quit

var hand_targets: Dictionary = {}
var hand_move_tween: Tween
var hand_tween: Tween
const HAND_OFFSET := 16.0
const HAND_SPEED := 0.25
const HAND_Y_OFFSET := 325.0

func _ready() -> void:
	var buttons = [start_button, controls_button, credits_button, quit_button]
	for button in buttons:
		button.mouse_entered.connect(func(): _on_menu_hover(button))
		button.focus_entered.connect(func(): _on_menu_hover(button))
	await get_tree().process_frame
	_cache_hand_targets(buttons)
	_on_menu_hover(start_button)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_credits_pressed() -> void:
	SceneTransition.change_scene_with_fade("res://scenes/credits.tscn")

func _on_start_pressed() -> void:
	SceneTransition.change_scene_with_fade("res://scenes/level_selector.tscn")


func _on_controls_pressed() -> void:
	SceneTransition.change_scene_with_fade("res://scenes/controls.tscn")

func _cache_hand_targets(buttons: Array) -> void:
	for button in buttons:
		hand_targets[button] = _get_hand_target(button)

func _get_hand_target(button: Control) -> Vector2:
	var target_y = button.get_global_rect().get_center().y
	return Vector2(hand.global_position.x, target_y + HAND_Y_OFFSET)

func _on_menu_hover(button: Button) -> void:
	var target = hand_targets.get(button, _get_hand_target(button))

	if hand_move_tween and hand_move_tween.is_running():
		hand_move_tween.kill()

	if hand_tween and hand_tween.is_running():
		hand_tween.kill()

	hand_move_tween = create_tween()
	hand_move_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	hand_move_tween.tween_property(hand, "global_position", target, 0.2)

	hand_move_tween.finished.connect(func(): _start_hand(target))

func _start_hand(target: Vector2) -> void:
	var base_position = target

	hand_tween = create_tween()
	hand_tween.set_loops()

	hand_tween.tween_method(
		func(value: float) -> void:
			hand.global_position = Vector2(base_position.x, base_position.y + sin(value) * HAND_OFFSET),
		0.0,
		TAU,
		HAND_SPEED * 4.0
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
