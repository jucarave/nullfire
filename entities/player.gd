extends CharacterBody2D
class_name Player

const SHOOT_LOWER_TIME: float = 1.0

var weapon: String = "gun"                  # This allows for changing weapon in the animation sprite
var is_animation_busy: bool = false         # The animations are usually controlled by a function, when this variable is true it means that we are busy playing an animation that must override the rest
var shooting_lower_delay: float = 0         # In seconds, how much time needs to pass to lower the gun after the last shot

@export var gravity: int = 10
@export var movement_speed: int = 128
@export var jump_force: int = -250

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ceiling_raycast: ShapeCast2D = $CeilingRaycast

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

func is_idle() -> bool:
	return velocity.x == 0 and is_on_floor()

func process_shoot() -> void:
	if  Input.is_action_just_pressed("shoot"):
		if shooting_lower_delay == 0 && is_idle():
			is_animation_busy = true
			sprite.play("idle_" + weapon + "_raise")
		shooting_lower_delay = SHOOT_LOWER_TIME

func process_sprite(delta: float) -> void:
	if is_animation_busy:
		return;
	
	var sprite_suffix: String = ""
	
	if shooting_lower_delay > 0:
		shooting_lower_delay -= delta
		sprite_suffix = "_aim"
		if shooting_lower_delay <= 0:
			shooting_lower_delay = 0
			
			if is_idle():
				is_animation_busy = true
				sprite.play("idle_" + weapon + "_lower")
				return
	
	if is_on_floor():
		if velocity.x != 0:
			sprite.play("run_" + weapon + sprite_suffix)
		else:
			sprite.play("idle_" + weapon + sprite_suffix)
	elif velocity.y > 0:
		sprite.play("fall_" + weapon + sprite_suffix)
	elif velocity.y < 0:
		sprite.play("jump_" + weapon + sprite_suffix)

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "idle_" + weapon + "_lower":
		is_animation_busy = false
	elif sprite.animation == "idle_" + weapon + "_raise":
		is_animation_busy = false
		sprite.play("idle_gun_aim")

func _process(delta: float) -> void:
	process_shoot()
	process_movement()
	process_jump()
	process_sprite(delta)

func _physics_process(_delta: float) -> void:
	# This is to prevent the frictioninig sliding on walls
	if is_on_wall() and velocity.y > 0:
		velocity.x = 0
	
	if not is_on_floor():
		velocity.y += gravity
	
	move_and_slide()
