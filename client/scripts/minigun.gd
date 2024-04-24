extends AudioStreamPlayer

func _process(delta):
	if Input.is_action_just_pressed("shoot"):
		$".".play()
	if Input.is_action_just_released("shoot"):
		$".".get_stream_playback().switch_to_clip_by_name("Minigun Shutdown")
