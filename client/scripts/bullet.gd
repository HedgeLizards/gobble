extends Area2D

const speed := 20.0 * 16
var distance := 256.0
var id: String

func _physics_process(delta):
	move_local_x(speed * delta)
	distance -= speed * delta
	if distance < 0:
		WebSocket.send({
			"type": "removeProjectile",
			"playerId": WebSocket.local_player_name,
			"id": id,
			"pos": [position.x / 16, position.y / 16],
		})
		queue_free()




func _on_area_entered(area: Area2D) -> void:
	if area.has_method("is_enemy") and area.is_enemy():
		
		WebSocket.send({
			"type": "impactProjectile",
			"playerId": WebSocket.local_player_name,
			"id": id,
			"pos": [position.x / 16, position.y / 16],
		})
		area.health -= 5
		queue_free()