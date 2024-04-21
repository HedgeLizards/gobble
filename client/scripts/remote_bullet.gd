extends Area2D

var speed: float
var distance: float
var is_enemy: bool
var id
var playerId
var damage

func _physics_process(delta):
	distance -= speed * delta
	if distance < 0:
		queue_free()
	move_local_x(speed * delta * 16)



func _on_body_entered(body: Node2D) -> void:
	if is_enemy && body.has_method("is_me") and body.is_me():
		WebSocket.send({
			"type": "impactProjectile",
			"playerId": playerId,
			"id": id,
			"impactedId": WebSocket.local_player_name,
			"pos": [position.x / 16, position.y / 16],
			"damage": damage,
		})
		queue_free()
