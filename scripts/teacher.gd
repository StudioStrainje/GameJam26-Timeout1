extends Node2D

signal teacher_moving

enum Direction { LEFT, RIGHT, DOWN }

@export var direction: Direction = Direction.RIGHT
@export var view_change_seconds := 7.0
@export var view_change_offset := 0.0
@export var slide_duration := 0.6
@export var pause_duration := 0.3
@export var idle_jitter := 2.0
@export var idle_speed := 30.0
@export var active_from_level := 1
@export var active_until_level := 999

@onready var game = $"/root/Game"
@onready var sprite: Sprite2D = $Sprite2D

var base_position := Vector2.ZERO
var offscreen_position := Vector2.ZERO
var t := 0.0
var teacher_view := 0
var view_timer := 0.0
var is_animating := false
var target_view := 0
var rng := RandomNumberGenerator.new()
var current_tween: Tween = null

func _ready() -> void:
	_calculate_positions()
	_setup_initial_state()

func _calculate_positions() -> void:
	var window := get_window()
	var window_size: Vector2i = window.size if window else Vector2i(1920, 1080)
	
	match direction:
		Direction.RIGHT:
			base_position = Vector2(500.0, -20.0)
			offscreen_position = Vector2(window_size.x + 100.0, -20.0)
		Direction.LEFT:
			base_position = Vector2(-500.0, 0.0)
			offscreen_position = Vector2(-window_size.x - 100.0, 0.0)
		Direction.DOWN:
			base_position = Vector2(0, -20.0)
			offscreen_position = Vector2(0, window_size.y + 100.0)

func _setup_initial_state() -> void:
	sprite.position = base_position
	teacher_view = _get_initial_teacher_view()
	view_timer = 0.0
	is_animating = false

func _get_teacher_num() -> int:
	match direction:
		Direction.RIGHT: return 1
		Direction.LEFT: return 2
		Direction.DOWN: return 3
		_: return 1

func _process(delta: float) -> void:
	if not _is_active_level():
		sprite.visible = false
		return
	
	if is_animating:
		_update_idle_animation(delta)
		return
	
	view_timer += delta
	
	if view_timer >= view_change_seconds + view_change_offset:
		view_timer = 0.0
		target_view = _get_next_teacher_view(teacher_view)
		_start_transition()
	
	_update_idle_animation(delta)
	_update_visibility()
	_check_collision()

func _is_active_level() -> bool:
	var level = game.level
	return level >= active_from_level and level <= active_until_level

func _start_transition() -> void:
	is_animating = true
	teacher_moving.emit()
	
	if current_tween:
		current_tween.kill()
	
	current_tween = create_tween()
	current_tween.set_ease(Tween.EASE_IN_OUT)
	current_tween.set_trans(Tween.TRANS_QUAD)
	
	current_tween.tween_property(sprite, "position", offscreen_position, slide_duration)
	current_tween.tween_interval(pause_duration)
	current_tween.tween_callback(_switch_to_target_view)
	current_tween.tween_property(sprite, "position", base_position, slide_duration)
	current_tween.tween_callback(_on_transition_complete)

func _switch_to_target_view() -> void:
	teacher_view = target_view
	_update_visibility()

func _on_transition_complete() -> void:
	is_animating = false

func _update_idle_animation(delta: float) -> void:
	if is_animating:
		return
	t += delta * idle_speed
	
	match direction:
		Direction.RIGHT, Direction.LEFT:
			sprite.position.x = base_position.x + sin(t) * idle_jitter
		Direction.DOWN:
			sprite.position.x = base_position.x + sin(t) * idle_jitter

func _update_visibility() -> void:
	var player_view = game.get_current_view()
	sprite.visible = (player_view == teacher_view) and _is_active_level()

func _check_collision() -> void:
	if game.copying == teacher_view and game.get_current_view() == teacher_view:
		game.trigger_level_failed("teacher")

func _get_initial_teacher_view() -> int:
	if direction == Direction.RIGHT:
		var view = game.get_current_view()
		if view == game.VIEW.DOWN:
			return _get_next_teacher_view(view)
		return view
	else:
		return _get_next_teacher_view(-1)

func _get_next_teacher_view(from_view: int) -> int:
	var candidates: Array[int] = []
	for i in range(game.VIEW.size()):
		if i != game.VIEW.DOWN:
			candidates.append(i)
	
	if candidates.is_empty():
		return game.VIEW.FORWARD
	
	if direction == Direction.RIGHT:
		var idx = candidates.find(from_view)
		if idx == -1:
			idx = 0
		return candidates[(idx + 1) % candidates.size()]
	else:
		var choice = candidates[rng.randi_range(0, candidates.size() - 1)]
		if choice == from_view and candidates.size() > 1:
			choice = candidates[(candidates.find(choice) + 1) % candidates.size()]
		return choice

func set_level_sprite() -> void:
	var idx = game.get_level_sprite_index()
	var sprite_path = game.teacher_sprite_paths[idx]
	sprite.texture = load(sprite_path)
	sprite.scale = game.get_sprite_scale(sprite_path)

func set_unique_sprite() -> void:
	var idx = game.get_unique_sprite_index()
	var sprite_path = game.teacher_sprite_paths[idx]
	sprite.texture = load(sprite_path)
	sprite.scale = game.get_sprite_scale(sprite_path)
