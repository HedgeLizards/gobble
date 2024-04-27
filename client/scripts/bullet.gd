extends Area2D

const speed := 60.0 * Globals.SCALE
var distance := 256.0
var id: String
const damage := 5.0

func _physics_process(delta):
	move_local_x(speed * delta)
	distance -= speed * delta
	if distance < 0:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("is_enemy") and area.is_enemy():
		WebSocket.send({
			"type": "impactProjectile",
			"creatorId": WebSocket.local_player_name,
			"id": id,
			"impactedId": area.id,
			"pos": [position.x / Globals.SCALE, position.y / Globals.SCALE],
			"damage": damage,
			"kind": "bullet",
		})
		queue_free()
