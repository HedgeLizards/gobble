extends CanvasLayer



func show_notice(notice, seconds = 2):
	$Notice.text = notice
	$Notice.modulate.a = 1
	
	if seconds != null:
		$NoticeTimer.start(seconds)
	elif !$NoticeTimer.is_stopped():
		$NoticeTimer.stop()

func hide_notice():
	create_tween().set_trans(Tween.TRANS_SINE).tween_property($Notice, 'modulate:a', 0, 0.5)
