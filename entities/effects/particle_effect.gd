extends AnimatedSprite2D
class_name ParticleEffect

func _ready() -> void:
	play("default")

func _on_animation_finished() -> void:
	queue_free()
