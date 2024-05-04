extends Node

const SCALE = 16.0

func _unhandled_key_input(event):
	if event.keycode == KEY_M and event.pressed and not event.echo:
		AudioServer.set_bus_mute(0, not AudioServer.is_bus_mute(0))
