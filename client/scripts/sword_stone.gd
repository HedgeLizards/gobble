extends Node2D

const SIZE = Vector2(2, 2)

var cell:
	set(value):
		cell = value
		
		position = (cell + SIZE / Vector2(2.0, 1.0)) * Globals.SCALE

func place():
	$SparkleParticles/CPUParticles2D.emitting = true
