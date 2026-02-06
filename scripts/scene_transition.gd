extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect

var is_transitioning: bool = false

func _ready() -> void:
	color_rect.color = Color.BLACK
	color_rect.modulate.a = 0.0

func fade_to_black(duration: float = 0.5) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, duration)
	await tween.finished

func fade_from_black(duration: float = 0.5) -> void:
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.0, duration)
	await tween.finished
	is_transitioning = false

func change_scene_with_fade(scene_path: String, fade_duration: float = 0.5) -> void:
	await fade_to_black(fade_duration)
	get_tree().change_scene_to_file(scene_path)
	await fade_from_black(fade_duration)
