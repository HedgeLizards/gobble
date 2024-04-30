extends CanvasGroup

var tween
var ratio = 1.0:
	set(value):
		if tween != null:
			tween.kill()
		
		tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_method(func(r): $Healthy.size.x = $Damage.size.x * r, ratio, value, 0.5)
		
		ratio = value

func resize_to_fit(label):
	var size = label.size * label.scale
	
	size.x = max(size.x + size.y / 2.0, 20.0)
	
	position.x = -size.x / 2.0
	
	$Damage.size = size
	$Healthy.size.y = size.y
	
	if tween == null || !tween.is_running():
		$Healthy.size.x = size.x * ratio
	
	material.set_shader_parameter('size', size)
