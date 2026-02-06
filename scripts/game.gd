extends Node2D

signal level_changed

@onready var forward_view: Node2D = %ForwardView
@onready var down_view: Node2D = %DownView
@onready var up_view: Node2D = %UpView
@onready var left_view: Node2D = %LeftView
@onready var right_view: Node2D = %RightView
@onready var level_label: Label = %Label
@onready var timer_label: Label = %TimerLabel

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

var rng = RandomNumberGenerator.new()

func get_current_view():
	return current_view

func get_level() -> int:
	return level

func get_cheating_views():
	return cheating_views

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
	level_label.text = "Level: " + str(level)
	reset_level_timer()
	SceneTransition.change_scene_with_fade("res://scenes/level_selector.tscn")

func _ready() -> void:
	var tree := get_tree()
	if tree and tree.has_meta("selected_level"):
		level = int(tree.get_meta("selected_level"))
		tree.remove_meta("selected_level")
	views = [down_view, forward_view, up_view, left_view, right_view]
	generate_new_level()
	level_label.text = "Level: " + str(level)
	reset_level_timer()
	update_timer_label()

func check_views():
	if Input.is_action_just_pressed("up"):
		match current_view:
			VIEW.FORWARD: current_view = VIEW.UP
			VIEW.DOWN: current_view = VIEW.FORWARD
			_: current_view = VIEW.UP
	if Input.is_action_just_pressed("down"):
		match current_view:
			VIEW.UP: current_view = VIEW.FORWARD
			VIEW.FORWARD: current_view = VIEW.DOWN
			_: current_view = VIEW.DOWN
	if Input.is_action_just_pressed("left"):
		match current_view:
			VIEW.RIGHT: current_view = VIEW.FORWARD
			_: current_view = VIEW.LEFT
	if Input.is_action_just_pressed("right"):
		match current_view:
			VIEW.LEFT: current_view = VIEW.FORWARD
			_: current_view = VIEW.RIGHT

func switch_view_visibility():
	for i in range(len(views)):
		views[i].visible = i == current_view

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
	var minutes := total_seconds / 60.0
	var seconds := total_seconds % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]

func trigger_level_failed(reason: String) -> void:
	if not level_failed:
		level_failed = true
		get_tree().set_meta("fail_reason", reason)
		SceneTransition.change_scene_with_fade("res://scenes/level_failed.tscn")
