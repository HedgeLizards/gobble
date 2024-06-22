extends Camera2D

const SCREEN_SIZE_RATIO = 320

var zoom_factor = 1.0:
	set(value):
		if value == zoom_factor:
			return
		
		var duration = abs(zoom_factor - value)
		
		zoom_factor = value
		
		if tween_zoom != null:
			tween_zoom.kill()
		
		tween_zoom = create_tween().set_trans(Tween.TRANS_SINE)
		tween_zoom.tween_property(self, 'zoom', calculate_dynamic_zoom(), duration)
var tween_zoom
var tween_offset

@onready var base_offset = offset

func _ready():
	get_viewport().size_changed.connect(
		func():
			if tween_zoom != null:
				tween_zoom.kill()
			
			zoom = calculate_dynamic_zoom()
	)
	
	zoom = calculate_dynamic_zoom()

func calculate_dynamic_zoom():
	var screen_scale = DisplayServer.screen_get_scale()
	var s = DisplayServer.window_get_size() / screen_scale  / (SCREEN_SIZE_RATIO * zoom_factor)
	var z = min(s.x, s.y)
	
	return Vector2(z, z) * screen_scale

func recoil(toward, strength):
	offset = base_offset + Vector2(-cos(toward), sin(toward)) * strength
	
	if tween_offset != null:
		tween_offset.kill()
	
	tween_offset = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween_offset.tween_property(self, 'offset', base_offset, strength / 6)
