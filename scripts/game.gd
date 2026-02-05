extends Node2D


@onready var forward_view: Node2D = %ForwardView
@onready var down_view: Node2D = %DownView
@onready var up_view: Node2D = %UpView
@onready var left_view: Node2D = %LeftView
@onready var right_view: Node2D = %RightView

var views: Array[Node2D]
var cheating_views: Array[VIEW]
var level: int = 1

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

func generate_new_level():
	cheating_views = []
	if level <= 3:
		for i in range(level):
			cheating_views.append(rng.randi_range(0, len(VIEW)))
	else:
		for i in range(3):
			cheating_views.append(rng.randi_range(1, len(VIEW)))
	print(cheating_views)

func _ready() -> void:
	views = [down_view, forward_view, up_view, left_view, right_view]
	generate_new_level()

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
