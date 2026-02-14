extends Node2D

signal teacher_moving

@onready var game = $"/root/Game"
@onready var sprite: Sprite2D = $Sprite2D
var prev_view = 0
var view = 0
var level = 0
var x = 0.0
var base_x := -500.0
var offset_x = 0.0
var t := 0.0
var teacher_view := 0
var display_view := 0
var pending_view := 0
var view_timer := 0.0
var slide_progress := 1.0
var is_sliding_out := false
var copying_grace_timer := 0.1
var rng := RandomNumberGenerator.new()
var is_waiting_to_depart := false
var pre_departure_timer := 0.0
var is_waiting_to_appear := false
var appear_timer := 0.0

@export var view_change_seconds := 7.0
@export var view_change_offset := 0.0
@export var slide_seconds := 0.35
@export var slide_from_right := true
@export var idle_jitter := 2.0
@export var idle_speed := 30.0
@export var copying_grace_seconds := 0.5
@export var pre_departure_delay := 1.0
@export var appear_delay := 0.5

func _ready() -> void:
	if get_window() != null:
		x = get_window().size.x + 25.0
	level = game.level
	slide_from_right = false
	offset_x = game.get_teacher_offset(2)
	sprite.position.x = base_x + offset_x
	teacher_view = _get_random_teacher_view()
	display_view = teacher_view
	pending_view = teacher_view
	prev_view = teacher_view
	view_timer = 0.0
	slide_progress = 1.0
	is_sliding_out = false
	copying_grace_timer = 0.0
	is_waiting_to_depart = false
	pre_departure_timer = 0.0
	is_waiting_to_appear = false
	appear_timer = 0.0
	_update_visibility_and_position(0.0)

func _process(delta: float) -> void:
	if not level == game.level:
		level = game.level
	view_timer += delta
	var is_active_level = level >= 2
	if not is_active_level:
		sprite.visible = false
		return
	if view_timer >= view_change_seconds + view_change_offset:
		view_timer = 0.0
		prev_view = teacher_view
		teacher_view = _get_random_teacher_view()
		pending_view = teacher_view
		teacher_moving.emit()
		if game.get_current_view() == display_view:
			is_waiting_to_depart = true
			pre_departure_timer = 0.0
		else:
			if game.get_current_view() == pending_view:
				is_waiting_to_appear = true
				appear_timer = 0.0
			else:
				display_view = pending_view
	_update_visibility_and_position(delta)
	if game.copying == display_view and game.get_current_view() == display_view and not is_waiting_to_appear:
		copying_grace_timer += delta
		if copying_grace_timer >= copying_grace_seconds:
			game.trigger_level_failed("teacher")
	else:
		copying_grace_timer = 0.0

func _update_visibility_and_position(delta: float) -> void:
	var is_current_view = game.get_current_view() == display_view
	sprite.visible = is_current_view and not is_waiting_to_appear
	if is_waiting_to_appear:
		appear_timer += delta
		if appear_timer >= appear_delay:
			is_waiting_to_appear = false
			display_view = pending_view
			slide_progress = 0.0
		return
	if not is_current_view:
		return
	if is_waiting_to_depart:
		pre_departure_timer += delta
		if pre_departure_timer >= pre_departure_delay:
			is_waiting_to_depart = false
			is_sliding_out = true
			slide_progress = 0.0
		else:
			return
	if is_sliding_out:
		slide_progress = min(slide_progress + (delta / max(slide_seconds, 0.001)), 1.0)
		var end_x = x if slide_from_right else -25.0
		sprite.position.x = lerp(base_x + offset_x, end_x, slide_progress)
		if slide_progress >= 1.0:
			is_sliding_out = false
			display_view = pending_view
			if game.get_current_view() == display_view:
				slide_progress = 0.0
		return
	if slide_progress < 1.0:
		slide_progress = min(slide_progress + (delta / max(slide_seconds, 0.001)), 1.0)
		var start_x = x if slide_from_right else -25.0
		sprite.position.x = lerp(start_x, base_x + offset_x, slide_progress)
		return
	t += delta * idle_speed
	sprite.position.x = base_x + offset_x + sin(t) * idle_jitter

func _get_random_teacher_view() -> int:
	var candidates: Array[int] = []
	for i in range(game.VIEW.size()):
		if i != game.VIEW.DOWN:
			candidates.append(i)
	if candidates.is_empty():
		return game.VIEW.FORWARD
	var choice = candidates[rng.randi_range(0, candidates.size() - 1)]
	if choice == display_view:
		choice = candidates[(candidates.find(choice) + 1) % candidates.size()]
	return choice

func _set_unique_sprite() -> void:
	var idx = game.get_unique_sprite_index()
	sprite.texture = load(game.teacher_sprite_paths[idx])