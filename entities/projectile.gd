extends Area2D
class_name Projectile

@export var time_to_live: float = 0.6                 # In seconds, to prevent bullets flying across the map
@export var velocity: float = 256

@onready var sprite: Sprite2D = $Sprite2D

signal on_destroy()

func initialize(mirrored: bool, offset: Vector2) -> void:
	sprite.flip_h = mirrored
	global_position.y += offset.y
	
	if mirrored:
		velocity *= -1
		global_position.x -= offset.x
	else:
		global_position.x += offset.x

func destroy() -> void:
	on_destroy.emit()
	queue_free()

func _on_body_entered(_body: Node2D) -> void:
	destroy()

func _process(delta: float) -> void:
	position.x += velocity * delta
	
	time_to_live -= delta
	if time_to_live <= 0:
		destroy()
