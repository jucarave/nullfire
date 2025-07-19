extends StaticBody2D

class_name Crate

@export var frame: int = 0                                  # Passed down to the sprite, allow us to change the appearance of the sprite
@export var destroyed_particles: PackedScene                # Particles to spawn once the box is destroyed

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	sprite.frame = frame

# Removes the crate and spawns a particle effect at the position
func destroy() -> void:
	var particle: DestroyedParticles = destroyed_particles.instantiate()
	particle.global_position = global_position
	get_tree().root.add_child(particle)
	
	queue_free()
