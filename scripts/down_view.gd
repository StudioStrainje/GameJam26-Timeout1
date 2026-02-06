extends Node2D

@onready var game: Node2D = $"/root/Game"
@onready var long_hand: Sprite2D = $LongHand
@onready var test: Sprite2D = $Test

var pps: float = 17.5 * 3
var is_pasting: bool = false

var progress_value: float = 0.0
var hand_start: Vector2
var hand_travel: Vector2
var time_accum: float = 0.0
var hand_reset_duration: float = 0.35
var text_fade_duration: float = 0.25

var this_view

func _ready() -> void:
	this_view = game.VIEW.DOWN
	progress_value = 0
	hand_start = long_hand.position
	_update_hand_travel()
	_reset_test_crop()

func _process(delta: float) -> void:
	if is_pasting:
		return

	if game.get_current_view() != this_view or game.copied_count == 0:
		return

	if Input.is_action_pressed("paste"):
		progress_value += pps * delta
		progress_value = clamp(progress_value, 0.0, 100.0)
		_update_test_crop(progress_value)
		_update_hand(progress_value, delta)

	if progress_value >= 100:
		_complete_paste()

func _complete_paste() -> void:
	is_pasting = true
	game.copied_count -= 1
	game.pasted_count += 1
	await _finish_paste_animation()

	if game.pasted_count == len(game.cheating_views):
		game.level_finished()

	progress_value = 0
	is_pasting = false

func _on_game_level_changed() -> void:
	progress_value = 0
	_reset_test_crop()
	is_pasting = false

func _reset_test_crop() -> void:
	if test.texture == null:
		return
	if not test.region_enabled:
		test.region_enabled = true
	test.region_rect = Rect2(Vector2.ZERO, Vector2.ZERO)
	var modulate := test.modulate
	modulate.a = 1.0
	test.modulate = modulate
	long_hand.position = hand_start

func _update_test_crop(value: float) -> void:
	if test.texture == null:
		return
	if not test.region_enabled:
		test.region_enabled = true
	var size: Vector2 = test.texture.get_size()
	var progress: float = clamp(value / 100.0, 0.0, 1.0)
	var crop_size := Vector2(size.x * progress, size.y * progress)
	test.region_rect = Rect2(Vector2.ZERO, crop_size)

func _update_hand_travel() -> void:
	if test.texture == null:
		return
	var world_size := test.texture.get_size() * test.scale
	hand_travel = Vector2(world_size.x, world_size.y)

func _update_hand(value: float, delta: float) -> void:
	_update_hand_travel()
	var progress: float = clamp(value / 100.0, 0.0, 1.0)
	time_accum += delta
	var perp_dir := Vector2(-1.0, 1.0).normalized()
	var bob := sin(time_accum * 10.0) * 8.0
	long_hand.position = hand_start + hand_travel * progress + perp_dir * bob

func _finish_paste_animation() -> void:
	var tween := create_tween()
	var modulate := test.modulate
	modulate.a = 1.0
	test.modulate = modulate
	tween.tween_property(long_hand, "position", hand_start, hand_reset_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(test, "modulate:a", 0.0, text_fade_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tween.finished
	_reset_test_crop()
