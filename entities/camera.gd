extends Camera2D
class_name CameraNullfire

const HORIZONTAL_DEAD_ZONE: float = 64
const VERTICAL_OFFSET: float = 32

var last_platform_y: float = -1

@export var player: Player
@export var follow_speed: float = 128

func _physics_process(delta: float) -> void:
	# Follow horizontally
	var delta_h: float = player.global_position.x - global_position.x
	if abs(delta_h) > HORIZONTAL_DEAD_ZONE:
		global_position.x = round(move_toward(global_position.x, player.global_position.x, follow_speed * delta))
	
	# Follow vertically
	if player.is_on_floor():
		last_platform_y = player.global_position.y
		global_position.y = round(lerp(global_position.y, last_platform_y - VERTICAL_OFFSET, 0.1))
	elif player.velocity.y > 0:
		global_position.y = round(max(global_position.y, player.global_position.y - VERTICAL_OFFSET))
	else:
		global_position.y = round(lerp(global_position.y, last_platform_y - VERTICAL_OFFSET, 0.1))
