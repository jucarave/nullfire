extends Area2D
class_name Treasure

const PICK_DISTANCE: float = 4

var player_node: Node2D = null

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_node = body

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_node = null

func _process(_delta: float) -> void:
	# Instead of destroying the item when the player collides with it I want to 
	# make sure that the player is close by
	if player_node != null:
		var dx: float = abs(player_node.global_position.x - global_position.x)
		if dx <= PICK_DISTANCE:
			queue_free()
