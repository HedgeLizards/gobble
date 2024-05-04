extends Area2D

@onready var color_rect_material = $ColorRect.material

func _ready():
	if OS.has_feature('web'):
		color_rect_material.set_shader_parameter('blur_center', 0.0)
		color_rect_material.set_shader_parameter('blur_edge', 0.0)
	
	var tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	tween.tween_method(func(value): color_rect_material.set_shader_parameter('progress', value), 0.0, 1.0, 0.8)
	tween.tween_callback(queue_free)
