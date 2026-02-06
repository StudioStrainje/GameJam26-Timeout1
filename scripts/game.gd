extends Node2D

signal level_changed

@onready var forward_view: Node2D = %ForwardView
@onready var down_view: Node2D = %DownView
@onready var up_view: Node2D = %UpView
@onready var left_view: Node2D = %LeftView
@onready var right_view: Node2D = %RightView
@onready var timer_label: Label = %TimerLabel
@onready var view_fade: ColorRect = %ViewFade

var views: Array[Node2D]
var cheating_views: Array[VIEW]
var level: int = 1
var copied_count = 0
var pasted_count = 0
var level_time_left := 60.0
var level_failed = false
var copying := -1
var level_time = 60.0

enum VIEW {
	DOWN,
	FORWARD,
	UP,
	LEFT,
	RIGHT
}

var current_view: VIEW = VIEW.FORWARD
var view_transition_duration := 0.8
var view_transition_tween: Tween
var is_view_transitioning := false

var rng = RandomNumberGenerator.new()

func get_current_view():
	return current_view

func get_level() -> int:
	return level

func get_cheating_views():
	return cheating_views

func get_pipik_multiplier():
	match level:
		1: return 1
		2: return .9
		3: return .8
		4: return .67
		5: return .5
	return 1

func gen_random_not_in_list(min_range: int, max_range: int, list: Array) -> int:
	var x: int = rng.randi_range(min_range, max_range)
	while x in list:
		x = rng.randi_range(min_range, max_range)
	return x

func generate_new_level():
	cheating_views = []
	if level < 3:
		for i in range(level):
			cheating_views.append(gen_random_not_in_list(1, len(VIEW)-1, cheating_views))
	else:
		for i in range(3):
			cheating_views.append(gen_random_not_in_list(1, len(VIEW)-1, cheating_views))
			
func load_score() -> int:
	if FileAccess.file_exists("user://score.int"):
		var file = FileAccess.open("user://score.int", FileAccess.READ)
		var value = file.get_var()
		file.close()
		return value
	return 1

func save_score(value: int):
	var file = FileAccess.open("user://score.int", FileAccess.WRITE)
	file.store_var(value)
	file.close()

func win_game():
	SceneTransition.change_scene_with_fade("res://scenes/winscreen.tscn")

func level_finished():
	level += 1
	if level == 6:
		win_game()
		return

	if level > load_score():
		save_score(level)
	generate_new_level()
	pasted_count = 0
	copied_count = 0
	level_changed.emit()
	reset_level_timer()
	SceneTransition.change_scene_with_fade("res://scenes/level_selector.tscn")

func _ready() -> void:
	var tree := get_tree()
	if tree and tree.has_meta("selected_level"):
		level = int(tree.get_meta("selected_level"))
		tree.remove_meta("selected_level")
	views = [down_view, forward_view, up_view, left_view, right_view]
	generate_new_level()
	reset_level_timer()
	update_timer_label()
	view_fade.modulate.a = 0.0

func check_views():
	if is_view_transitioning:
		return
	var target_view := current_view
	if Input.is_action_just_pressed("up"):
		match current_view:
			VIEW.FORWARD: target_view = VIEW.UP
			VIEW.DOWN: target_view = VIEW.FORWARD
			_: target_view = VIEW.UP
	if Input.is_action_just_pressed("down"):
		match current_view:
			VIEW.UP: target_view = VIEW.FORWARD
			VIEW.FORWARD: target_view = VIEW.DOWN
			_: target_view = VIEW.DOWN
	if Input.is_action_just_pressed("left"):
		match current_view:
			VIEW.RIGHT: target_view = VIEW.FORWARD
			_: target_view = VIEW.LEFT
	if Input.is_action_just_pressed("right"):
		match current_view:
			VIEW.LEFT: target_view = VIEW.FORWARD
			_: target_view = VIEW.RIGHT
	if target_view != current_view:
		_transition_to_view(target_view)

func switch_view_visibility():
	for i in range(len(views)):
		views[i].visible = i == current_view

func _fade_view(target_alpha: float, duration: float) -> void:
	if view_transition_tween:
		view_transition_tween.kill()
	view_transition_tween = create_tween()
	view_transition_tween.tween_property(view_fade, "modulate:a", target_alpha, duration)
	await view_transition_tween.finished

func _transition_to_view(target_view: VIEW) -> void:
	is_view_transitioning = true
	await _fade_view(1.0, view_transition_duration * 0.5)
	current_view = target_view
	switch_view_visibility()
	await _fade_view(0.0, view_transition_duration * 0.5)
	is_view_transitioning = false

func print_view():
	match current_view:
		VIEW.DOWN: print("down")
		VIEW.FORWARD: print("forward")
		VIEW.UP: print("up")
		VIEW.LEFT: print("left")
		VIEW.RIGHT: print("right")

func _process(_delta: float) -> void:
	check_views()
	switch_view_visibility()
	update_level_timer(_delta)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		get_viewport().set_input_as_handled()
		toggle_escape_menu()

func toggle_escape_menu():
	var existing_menu = get_tree().root.get_node_or_null("EscapeMenu")
	if existing_menu:
		existing_menu.close_menu()
	else:
		var escape_menu = load("res://scenes/escape.tscn").instantiate()
		escape_menu.name = "EscapeMenu"
		escape_menu.process_mode = Node.PROCESS_MODE_ALWAYS
		get_tree().root.add_child(escape_menu)
		get_tree().paused = true

func reset_level_timer() -> void:
	level_time_left = level_time
	update_timer_label()

func update_level_timer(delta: float) -> void:
	level_time_left = max(level_time_left - delta, 0.0)
	update_timer_label()
	if level_time_left <= 0.0:
		trigger_level_failed("time")

func update_timer_label() -> void:
	var total_seconds := int(ceil(level_time_left))
	timer_label.text = "%02d" % total_seconds

func trigger_level_failed(reason: String) -> void:
	if not level_failed:
		level_failed = true
		get_tree().set_meta("fail_reason", reason)
		SceneTransition.change_scene_with_fade("res://scenes/level_failed.tscn")
