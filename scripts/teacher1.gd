extends Node2D

@onready var game = $"/root/Game"
@onready var sprite: Sprite2D = $Sprite2D
var prev_view = 0
var view = 0
var level = 0
var x = 0.0
var base_x := 250.0
var t := 0.0
var teacher_view := 0
var display_view := 0
var pending_view := 0
var view_timer := 0.0
var slide_progress := 1.0
var is_sliding_out := false
var copying_grace_timer := 0.0

@export var view_change_seconds := 7.0
@export var view_change_offset := 0.0
@export var slide_seconds := 0.35
@export var slide_from_right := true
@export var idle_jitter := 2.0
@export var idle_speed := 30.0
@export var copying_grace_seconds := 0.5

func _ready() -> void:
	if get_window() != null:
		x = get_window().size.x + 25.0
	level = game.level
	var y = "res://assets/teachers/lvl" + str(level) + ".png"
	sprite.texture = load(y)
	base_x = 250.0
	sprite.position.x = base_x
	teacher_view = game.get_current_view()
	if teacher_view == game.VIEW.DOWN:
		teacher_view = _get_next_teacher_view(teacher_view)
	display_view = teacher_view
	pending_view = teacher_view
	prev_view = teacher_view
	view_timer = 0.0
	slide_progress = 1.0
	is_sliding_out = false
	copying_grace_timer = 0.0
	_update_visibility_and_position(0.0)

func _process(delta: float) -> void:
	if not level == game.level:
		level = game.level
		var y = "res://assets/teachers/lvl" + str(level) + ".png"
		sprite.texture = load(y)
	view_timer += delta
	if view_timer >= view_change_seconds + view_change_offset:
		view_timer = 0.0
		prev_view = teacher_view
		teacher_view = _get_next_teacher_view(teacher_view)
		if game.get_current_view() == display_view:
			pending_view = teacher_view
			is_sliding_out = true
			slide_progress = 0.0
		else:
			display_view = teacher_view
			if game.get_current_view() == display_view:
				slide_progress = 0.0
	_update_visibility_and_position(delta)
	if game.copying == display_view and game.get_current_view() == display_view:
		copying_grace_timer += delta
		if copying_grace_timer >= copying_grace_seconds:
			game.trigger_level_failed()
	else:
		copying_grace_timer = 0.0

func _update_visibility_and_position(delta: float) -> void:
	var is_current_view = game.get_current_view() == display_view
	sprite.visible = is_current_view
	if not is_current_view:
		return
	if is_sliding_out:
		slide_progress = min(slide_progress + (delta / max(slide_seconds, 0.001)), 1.0)
		var end_x = x if slide_from_right else -25.0
		sprite.position.x = lerp(base_x, end_x, slide_progress)
		if slide_progress >= 1.0:
			is_sliding_out = false
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
