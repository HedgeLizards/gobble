extends Area2D

func _ready():
	var tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	tween.tween_method(func(value): $ColorRect.material.set_shader_parameter('progress', value), 0.0, 1.0, 0.8)
	tween.tween_callback(queue_free)
