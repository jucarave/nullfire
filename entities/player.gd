extends CharacterBody2D
class_name Player

const SHOOT_LOWER_TIME: float = 1.0

var weapon: String = "gun"                  # This allows for changing weapon in the animation sprite
var is_animation_busy: bool = false         # The animations are usually controlled by a function, when this variable is true it means that we are busy playing an animation that must override the rest
var shooting_lower_delay: float = 0         # In seconds, how much time needs to pass to lower the gun after the last shot
var projectile: Projectile = null           # Current projectile
var flip_h: bool = false                    # Is the player looking to the left?

@export var gravity: int = 10
@export var movement_speed: int = 128
@export var jump_force: int = -250
@export var projectile_scene: PackedScene

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ceiling_raycast: ShapeCast2D = $CeilingRaycast
@onready var projectile_spawn_point: Node2D = $ProjectileSpawnPoint

func get_sprite_suffix() -> String:
	var facing_direction: String = "r_"
	if flip_h:
		facing_direction = "l_"
	
	return facing_direction + weapon

func process_movement() -> void:
	var hor: float = Input.get_axis("left", "right")
	
	if hor != 0.0:
		velocity.x = movement_speed * hor
		flip_h = hor < 0;
	else:
		velocity.x = 0

func process_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor() and not ceiling_raycast.is_colliding():
		velocity.y = jump_force

func is_idle() -> bool:
	return velocity.x == 0 and is_on_floor()

func on_projectile_destroy() -> void:
	projectile.on_destroy.disconnect(on_projectile_destroy)
	projectile = null

func spawn_projectile() -> void:
	if projectile != null:
		return
	
	projectile = projectile_scene.instantiate()
	get_tree().root.add_child(projectile)
	projectile.global_position = global_position
	projectile.initialize(flip_h, projectile_spawn_point.position)
	projectile.on_destroy.connect(on_projectile_destroy)

func process_shoot() -> void:
	if  Input.is_action_just_pressed("shoot"):
		if shooting_lower_delay == 0 and is_idle():
			is_animation_busy = true
			sprite.play("idle_" + get_sprite_suffix() + "_raise")
		
		if shooting_lower_delay > 0 or not is_idle():
			spawn_projectile()
		
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
				sprite.play("idle_" + get_sprite_suffix() + "_lower")
				return
	
	if is_on_floor():
		if velocity.x != 0:
			sprite.play("run_" + get_sprite_suffix() + sprite_suffix)
		else:
			sprite.play("idle_" + get_sprite_suffix() + sprite_suffix)
	elif velocity.y > 0:
		sprite.play("fall_" + get_sprite_suffix() + sprite_suffix)
	elif velocity.y < 0:
		sprite.play("jump_" + get_sprite_suffix() + sprite_suffix)

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "idle_" + get_sprite_suffix() + "_lower":
		is_animation_busy = false
	elif sprite.animation == "idle_" + get_sprite_suffix() + "_raise":
		is_animation_busy = false
		spawn_projectile()
		sprite.play("idle_" + get_sprite_suffix() + "_aim")

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
