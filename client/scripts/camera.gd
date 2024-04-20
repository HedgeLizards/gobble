extends Camera2D

const screen_size_ratio = 256

func _process(delta: float) -> void:
	var s = DisplayServer.window_get_size() / screen_size_ratio
	var z = max(0, floor(min(s.x, s.y)))
	zoom = Vector2(z, z)

