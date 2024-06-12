extends TextureRect


func _ready() -> void:
	visible = Globals.touch_controls_enabled


func _on_gui_input(event: InputEvent) -> void:
	print(event)
