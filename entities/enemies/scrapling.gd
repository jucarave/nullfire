extends CharacterBody2D
class_name Scrapling

@export var speed: float = 32

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var wall_raycast: RayCast2D = $WallRaycast
@onready var ledge_raycast: RayCast2D = $LedgeRaycast

func _ready() -> void:
	sprite.play("walk_r")
	velocity.x = speed

# Changes the movement from left to right and viceversa
# also changes the animation being played and the raycasts
# positions for checking walls and ledges
func turn_around() -> void:
	velocity.x *= -1
	wall_raycast.target_position.x *= -1
	ledge_raycast.position.x *= -1
	
	if velocity.x < 0:
		sprite.play("walk_l")
	else:
		sprite.play("walk_r")

func _physics_process(_delta: float) -> void:
	if wall_raycast.is_colliding():
		turn_around()
	
	if not ledge_raycast.is_colliding():
		turn_around()
	
	move_and_slide()
