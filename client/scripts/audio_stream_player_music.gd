extends AudioStreamPlayer

func _process(delta):
	if Input.is_action_just_pressed("1"):
		get_stream_playback().switch_to_clip_by_name("Mus 1")
	if Input.is_action_just_pressed("2"):
		get_stream_playback().switch_to_clip_by_name("Trans 1 to 2")
	if Input.is_action_just_pressed("3"):
		get_stream_playback().switch_to_clip_by_name("Trans 2 to 3")

