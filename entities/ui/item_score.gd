extends Node2D
class_name ItemScore

@export var speed: float = 48
@export var time_to_live: float = 2

func set_text(text: String) -> void:
	($Label as Label).text = text

func _process(delta: float) -> void:
	position.y -= speed * delta
	
	time_to_live -= delta
	if time_to_live <= 0:
		queue_free()
