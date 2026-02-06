extends Node2D

signal level_changed

@onready var forward_view: Node2D = %ForwardView
@onready var down_view: Node2D = %DownView
@onready var up_view: Node2D = %UpView
@onready var left_view: Node2D = %LeftView
@onready var right_view: Node2D = %RightView
@onready var level_label: Label = %Label

var views: Array[Node2D]
var cheating_views: Array[VIEW]
var level: int = 1
var copied_count = 0
var pasted_count = 0

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

func level_finished():
	level += 1
	if level > load_score():
		save_score(level)
	generate_new_level()
	pasted_count = 0
	copied_count = 0
	level_changed.emit()
	level_label.text = "Level: " + str(level)
	get_tree().change_scene_to_file("res://scenes/level_selector.tscn")

func _ready() -> void:
	var tree := get_tree()
	if tree and tree.has_meta("selected_level"):
		level = int(tree.get_meta("selected_level"))
		tree.remove_meta("selected_level")
	views = [down_view, forward_view, up_view, left_view, right_view]
	generate_new_level()
	level_label.text = "Level: " + str(level)

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
