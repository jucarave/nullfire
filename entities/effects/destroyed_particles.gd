extends Node2D
class_name DestroyedParticles

const GRAVITY: float = 10

var speeds: Array[Vector2]                         # Instead of creating classes for the sprites I just keep their speeds here
var time_to_live: float = 1                        # In seconds, how long to destroy the particles

@export var particles: Array[Sprite2D]             # Sprites used to animate the effect, it should only be 4

func _ready() -> void:
	speeds = [
		Vector2(32, -256),
		Vector2(16, -200),
		Vector2(-32, -200),
		Vector2(-48, -256),
	]

func _process(delta: float) -> void:
	var i: int = 0
	for particle: Sprite2D in particles:
		speeds[i].y += GRAVITY
		particle.position += speeds[i] * delta
		
		i += 1
	
	time_to_live -= delta
	if time_to_live <= 0:
		queue_free()
