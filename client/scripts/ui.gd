extends CanvasLayer

var gold := -1:
	set(value):
		if value == gold:
			return
		
		if value > gold && gold != -1:
			if tween != null:
				tween.kill()
			
			tween = create_tween().set_trans(Tween.TRANS_SINE)
			tween.tween_property($Gold, 'scale', Vector2.ONE * (1.0 + (value - gold) * 0.2), 0.2).set_ease(Tween.EASE_OUT)
			tween.tween_property($Gold, 'scale', Vector2.ONE, 0.2).set_ease(Tween.EASE_IN)
		
		gold = value
		
		$Gold/Label.text = str(gold)
var tween

func _ready():
	var screen_scale = DisplayServer.screen_get_scale()
	
	$Gold.add_theme_constant_override('separation',
		$Gold.get_theme_constant('separation') * screen_scale
	)
	$Gold/TextureRect.custom_minimum_size *= screen_scale
	$Gold/Label.add_theme_font_size_override('font_size',
		$Gold/Label.get_theme_font_size('font_size') * screen_scale
	)
	
	$Notice.add_theme_font_size_override('normal_font_size',
		$Notice.get_theme_font_size('normal_font_size') * screen_scale
	)

func _on_gold_resized():
	$Gold.pivot_offset = $Gold.size / 2.0

func show_notice(notice, seconds = 2.0):
	$Notice.text = notice
	$Notice.modulate.a = 1.0
	
	if seconds != null:
		$NoticeTimer.start(seconds)
	elif !$NoticeTimer.is_stopped():
		$NoticeTimer.stop()

func hide_notice():
	create_tween().set_trans(Tween.TRANS_SINE).tween_property($Notice, 'modulate:a', 0.0, 0.5)
