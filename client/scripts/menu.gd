extends Control

func _on_join_pressed():
	var local_player_name = $VBoxContainer/Identity/Name.text
	
	if local_player_name.is_empty():
		return
	
	WebSocket.local_player_name = local_player_name
	WebSocket.connect_to_host($VBoxContainer/Connection/Host.text)
