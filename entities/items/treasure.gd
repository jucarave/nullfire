extends Area2D
class_name Treasure

const PICK_DISTANCE: float = 8

var player_node: Node2D = null

@export var score: int
@export var item_score: PackedScene

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_node = body

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_node = null

# Creates a ui label showing the value of the treasure
func spawn_score() -> void:
	var score_entity: ItemScore = item_score.instantiate()
	score_entity.global_position = global_position
	score_entity.set_text(str(score))
	get_tree().root.add_child(score_entity)

func _process(_delta: float) -> void:
	# Instead of destroying the item when the player collides with it I want to 
	# make sure that the player is close by
	if player_node != null:
		var dx: float = abs(player_node.global_position.x - global_position.x)
		if dx <= PICK_DISTANCE:
			spawn_score()
			queue_free()
			
			GameSession.get_instance().score += score
