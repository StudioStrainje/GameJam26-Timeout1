extends Control

@onready var sprite: Sprite2D = $Sprite2D
@onready var mobile_overlay: Control = $MobileOverlay

var is_mobile: bool = false

func _ready() -> void:
	is_mobile = _check_is_mobile()
	_setup_controls_display()

func _check_is_mobile() -> bool:
	if OS.has_feature("android"):
		return true
	if OS.has_feature("web"):
		if DisplayServer.is_touchscreen_available():
			return true
		var nav = JavaScriptBridge.get_interface("navigator")
		if is_instance_valid(nav):
			var js_code = "(function() { return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent); })()"
			var result = JavaScriptBridge.eval(js_code)
			if result == true:
				return true
	return false

func _setup_controls_display() -> void:
	if is_mobile:
		sprite.texture = load("res://assets/controls-no-text.png")
		mobile_overlay.visible = true
	else:
		mobile_overlay.visible = false

func _on_back_pressed() -> void:
	SceneTransition.change_scene_with_fade("res://scenes/mainmenu.tscn")
