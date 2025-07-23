extends Area2D
class_name Projectile

signal on_destroy()

@export var time_to_live: float = 0.6                 # In seconds, to prevent bullets flying across the map
@export var velocity: float = 256
@export var collision_particles_scene: PackedScene

@onready var sprite: Sprite2D = $Sprite2D

# Flips the sprite and sets its position relative to the
# shooter depending if it's looking to the left or right
func initialize(mirrored: bool, offset: Vector2) -> void:
	sprite.flip_h = mirrored
	global_position.y += offset.y
	
	if mirrored:
		velocity *= -1
		global_position.x -= offset.x
	else:
		global_position.x += offset.x

# Creates a particle effect animation of the bullet exploding
# to be called when it collides with something
func spawn_collision_particles() -> void:
	var particles: Node2D = collision_particles_scene.instantiate()
	get_tree().root.add_child(particles)
	particles.global_position = global_position

# If someone is listening then let them know that this object
# is to be destroyed
func destroy() -> void:
	on_destroy.emit()
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is Crate:
		(body as Crate).destroy()
	
	spawn_collision_particles()
	destroy()

func _process(delta: float) -> void:
	position.x += velocity * delta
	
	time_to_live -= delta
	if time_to_live <= 0:
		destroy()
