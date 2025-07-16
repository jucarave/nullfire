extends CharacterBody2D
class_name Player

@export var gravity: int = 10
@export var movement_speed: int = 128
@export var jump_force: int = -250

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ceiling_raycast: RayCast2D = $CeilingRaycast

func process_movement() -> void:
	var hor: float = Input.get_axis("left", "right")
	
	if hor != 0.0:
		velocity.x = movement_speed * hor
		sprite.flip_h = hor < 0;
	else:
		velocity.x = 0

func process_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor() and not ceiling_raycast.is_colliding():
		velocity.y = jump_force

func process_sprite() -> void:
	if is_on_floor():
		if velocity.x != 0:
			sprite.play("run")
		else:
			sprite.play("idle")
	elif velocity.y > 0:
		sprite.play("fall")
	elif velocity.y < 0:
		sprite.play("jump")
	

func _process(_delta: float) -> void:
	process_movement()
	process_jump()
	process_sprite()

func _physics_process(_delta: float) -> void:
	# This is to prevent the frictioninig sliding on walls
	if is_on_wall() and velocity.y > 0:
		velocity.x = 0
	
	if not is_on_floor():
		velocity.y += gravity
	
	move_and_slide()
