extends Node2D

@onready var game = $"/root/Game"
@onready var sprite: Sprite2D = $Sprite2D
var prev_view = 0
var view = 0
var level = 0
var x = 0.0
var base_x := -500.0
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
var is_waiting_between_views := false
var inter_view_timer := 0.0
var move_sound_player: AudioStreamPlayer

@export var view_change_seconds := 7.0
@export var view_change_offset := 0.0
@export var slide_seconds := 0.35
@export var slide_from_right := true
@export var idle_jitter := 2.0
@export var idle_speed := 30.0
@export var copying_grace_seconds := 0.5
@export var pre_departure_delay := 1.0
@export var inter_view_delay := 1.0
@export var move_sound: AudioStream = preload("res://assets/teachers/sounds/4.wav")
@export var random_teacher_paths := [
	"res://assets/teachers/lvl1.png",
	"res://assets/teachers/lvl2.png",
	"res://assets/teachers/lvl3.png",
	"res://assets/teachers/lvl4.png",
	"res://assets/teachers/lvl5.png"
]

func _ready() -> void:
	if get_window() != null:
		x = get_window().size.x + 25.0
	level = game.level
	_set_random_teacher_sprite()
	slide_from_right = false
	sprite.position.x = base_x
	move_sound_player = AudioStreamPlayer.new()
	move_sound_player.stream = move_sound
	add_child(move_sound_player)
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
	is_waiting_between_views = false
	inter_view_timer = 0.0
	_update_visibility_and_position(0.0)

func _process(delta: float) -> void:
	if not level == game.level:
		level = game.level
		_set_random_teacher_sprite()
	view_timer += delta
	var is_active_level = level == 4 or level == 5
	if not is_active_level:
		sprite.visible = false
		return
	if view_timer >= view_change_seconds + view_change_offset:
		view_timer = 0.0
		prev_view = teacher_view
		teacher_view = _get_random_teacher_view()
		pending_view = teacher_view
		if game.get_current_view() == display_view:
			is_waiting_to_depart = true
			pre_departure_timer = 0.0
			_play_move_sound()
		else:
			_start_inter_view_delay()
	_update_visibility_and_position(delta)
	if game.copying == display_view and game.get_current_view() == display_view:
		copying_grace_timer += delta
		if copying_grace_timer >= copying_grace_seconds:
			game.trigger_level_failed("teacher")
	else:
		copying_grace_timer = 0.0

func _update_visibility_and_position(delta: float) -> void:
	var is_current_view = game.get_current_view() == display_view
	sprite.visible = is_current_view
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
		sprite.position.x = lerp(base_x, end_x, slide_progress)
		if slide_progress >= 1.0:
			is_sliding_out = false
			_start_inter_view_delay()
		return
	if is_waiting_between_views:
		inter_view_timer += delta
		if inter_view_timer >= inter_view_delay:
			is_waiting_between_views = false
			display_view = pending_view
			if game.get_current_view() == display_view:
				slide_progress = 0.0
		return
	if slide_progress < 1.0:
		slide_progress = min(slide_progress + (delta / max(slide_seconds, 0.001)), 1.0)
		var start_x = x if slide_from_right else -25.0
		sprite.position.x = lerp(start_x, base_x, slide_progress)
		return
	t += delta * idle_speed
	sprite.position.x = base_x + sin(t) * idle_jitter

func _get_next_teacher_view(from_view: int) -> int:
	var next_view = from_view
	for _i in range(game.VIEW.size()):
		next_view = (next_view + 1) % game.VIEW.size()
		if next_view != game.VIEW.DOWN:
			return next_view
	return game.VIEW.FORWARD

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

func _set_random_teacher_sprite() -> void:
	if random_teacher_paths.is_empty():
		return
	var idx = rng.randi_range(0, random_teacher_paths.size() - 1)
	sprite.texture = load(random_teacher_paths[idx])

func _start_inter_view_delay() -> void:
	is_waiting_between_views = true
	inter_view_timer = 0.0

func _play_move_sound() -> void:
	if move_sound_player and move_sound_player.stream:
		move_sound_player.play()
