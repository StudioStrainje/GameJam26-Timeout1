extends Node2D

@onready var game: Node2D = $"/root/Game"
@onready var clean: Node2D = $Clean
@onready var cheat: Node2D = $Cheat
@onready var progress_bar: TextureProgressBar = $ProgressBar/Sprite2D2/ProgressBar
@onready var speech_bubble: CanvasLayer = $SpeechBubble
@onready var speech_panel: PanelContainer = $SpeechBubble/Bubble

var pps: float = 17.5
var dementia_pps: float = 4.67
var completed = false
var speech_tween: Tween

var this_view

func _ready() -> void:
	pps = 17.5 * game.get_pipik_multiplier()
	this_view = game.VIEW.FORWARD
	progress_bar.value = 0.0
	speech_bubble.visible = false
	speech_panel.modulate.a = 0.0
	_show_teacher_warning_if_needed()


func _process(delta: float) -> void:
	if game.get_current_view() == this_view:
		if this_view in game.get_cheating_views():
			cheat.visible = true
			clean.visible = false
			
			if Input.is_action_pressed("copy"):
				game.copying = this_view
				progress_bar.value += pps * delta
			else:
				game.copying = -1
				if progress_bar.value < 100:
					progress_bar.value -= dementia_pps * delta
				if progress_bar.value <= 0:
					completed = false
			if progress_bar.value >= 100 and not completed:
				game.copied_count += 1
				completed = true

		else:
			cheat.visible = false
			clean.visible = true
	else:
		if progress_bar.value < 100:
			progress_bar.value -= dementia_pps * delta


func _on_game_level_changed() -> void:
	progress_bar.value = 0
	completed = false
	_show_teacher_warning_if_needed()

func _show_teacher_warning_if_needed() -> void:
	if not speech_bubble:
		return
	if not _is_teacher_in_forward_view():
		speech_bubble.visible = false
		speech_panel.modulate.a = 0.0
		return
	if speech_tween:
		speech_tween.kill()
	speech_bubble.visible = true
	speech_panel.modulate.a = 0.0
	speech_tween = create_tween()
	speech_tween.tween_property(speech_panel, "modulate:a", 1.0, 0.4)
	speech_tween.tween_interval(2.4)
	speech_tween.tween_property(speech_panel, "modulate:a", 0.0, 0.5)
	speech_tween.finished.connect(func():
		speech_bubble.visible = false
	)

func _is_teacher_in_forward_view() -> bool:
	var teacher1 = game.get_node_or_null("Teacher1")
	if teacher1 and teacher1.has_method("get_display_view"):
		if teacher1.get_display_view() == game.VIEW.FORWARD:
			return true
	var teacher2 = game.get_node_or_null("Teacher2")
	if teacher2 and teacher2.has_method("get_display_view"):
		var is_active = true
		if teacher2.has_method("is_active"):
			is_active = teacher2.is_active()
		if is_active and teacher2.get_display_view() == game.VIEW.FORWARD:
			return true
	return false
