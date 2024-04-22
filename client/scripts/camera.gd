extends Camera2D

const SCREEN_SIZE_RATIO = 320

var tween
@onready var base_offset = offset

func _ready():
	get_viewport().size_changed.connect(zoom_dynamically)
	
	zoom_dynamically()

func zoom_dynamically():
	var s = DisplayServer.window_get_size() / DisplayServer.screen_get_scale() / SCREEN_SIZE_RATIO
	var z = min(s.x, s.y)
	
	zoom = Vector2(z, z) * DisplayServer.screen_get_scale()

func recoil(toward, strength):
	offset = base_offset + Vector2(-cos(toward), sin(toward)) * strength
	
	if tween != null:
		tween.kill()
	
	tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, 'offset', base_offset, strength / 6)
