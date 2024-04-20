extends Camera2D

const screen_size_ratio = 256

func _process(delta: float) -> void:
	var s = DisplayServer.window_get_size() / DisplayServer.screen_get_scale() / screen_size_ratio
	var z = max(0, min(s.x, s.y))
	zoom = Vector2(z, z) * DisplayServer.screen_get_scale()

