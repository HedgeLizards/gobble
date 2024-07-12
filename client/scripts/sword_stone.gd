extends Node2D

const SIZE = Vector2(2, 2)

var cell:
	set(value):
		cell = value
		
		position = (cell + SIZE / Vector2(2.0, 1.0)) * Globals.SCALE
var health:
	set(value):
		if value == 0:
			Music.get_stream_playback().switch_to_clip_by_name("Trans 2 to 3")
			
			$Sprite2D.texture = preload('res://assets/Buildings/Stone_empty.png')
			$Sprite2D.offset.y += 9
		elif health == 0:
			Music.get_stream_playback().switch_to_clip_by_name("Mus 2")
			
			$Sprite2D.texture = preload('res://assets/Buildings/Stone_sword.png')
			$Sprite2D.offset.y -= 9
		
		health = value

func place():
	$SparkleParticles/CPUParticles2D.emitting = true
