extends CharacterBody2D
class_name Player

const SHOOT_LOWER_TIME: float = 1.0         # In seconds, max time to lower the gun after the last shot

var weapon: String = "gun"                  # This allows for changing weapon in the animation sprite
var is_animation_busy: bool = false         # The animations are usually controlled by a function, when this variable is true it means that we are busy playing an animation that must override the rest
var shooting_lower_delay: float = 0         # In seconds, how much time needs to pass to lower the gun after the last shot
var projectile: Projectile = null           # Current projectile
var flip_h: bool = false                    # Is the player looking to the left?
var was_on_floor: bool = true               # Was the player on the floor? this is used to spawn the dust particles

@export var gravity: int = 10
@export var movement_speed: int = 128
@export var jump_force: int = -250
@export var projectile_scene: PackedScene
@export var dust_particles_scene: PackedScene

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ceiling_raycast: ShapeCast2D = $CeilingRaycast
@onready var projectile_spawn_point: Node2D = $ProjectileSpawnPoint
@onready var dust_particles_spawn_point: Node2D = $DustParticlesSpawnPoint

# Checks if the player has made contact with the floor and if so then 
# create a dust particles animation
func check_and_spawn_dust_particles() -> void:
	if is_on_floor() and not was_on_floor:
		was_on_floor = true
		var particles: Node2D = dust_particles_scene.instantiate()
		particles.global_position = dust_particles_spawn_point.global_position
		get_tree().root.add_child(particles)

# Returns either l_(weapon) or r_(weapon) depending on if the player
# is looking to the left or right
func get_sprite_suffix() -> String:
	var facing_direction: String = "r_"
	if flip_h:
		facing_direction = "l_"
	
	return facing_direction + weapon

# Sets the horizontal velocity for the characterBody2D
# the actual movement happens in the _physics_process method
func process_movement() -> void:
	if is_animation_busy:
		return
	
	var hor: float = Input.get_axis("left", "right")
	
	if hor != 0.0:
		velocity.x = movement_speed * hor
		flip_h = hor < 0;
	else:
		velocity.x = 0

# Allows for jumping if the player is on the floor and there isn't
# a block right on top of the player
func process_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor() and not ceiling_raycast.is_colliding():
		velocity.y = jump_force

# If the player isn't moving and it's on the floor then we can think
# that they are idling
func is_idle() -> bool:
	return velocity.x == 0 and is_on_floor()

# We only allow one projectile at the time, so setting it to null once the
# projectile is destroyed allow us to control this
func on_projectile_destroy() -> void:
	projectile.on_destroy.disconnect(on_projectile_destroy)
	projectile = null

# Only create a projectile if there isn't another one already in
# the game, connect it to on_projectile_destroy() to allow the 
# player to shoot again once it is destroyed
func spawn_projectile() -> void:
	if projectile != null:
		return
	
	projectile = projectile_scene.instantiate()
	get_tree().root.add_child(projectile)
	projectile.global_position = global_position
	projectile.initialize(flip_h, projectile_spawn_point.position)
	projectile.on_destroy.connect(on_projectile_destroy)

# If the player shoots and they are idling then change to the raising
# gun animation, otherwise spawn the projectile immediately
func process_shoot() -> void:
	if  Input.is_action_just_pressed("shoot"):
		if shooting_lower_delay == 0 and is_idle():
			is_animation_busy = true
			sprite.play("idle_" + get_sprite_suffix() + "_raise")
		
		if shooting_lower_delay > 0 or not is_idle():
			spawn_projectile()
		
		shooting_lower_delay = SHOOT_LOWER_TIME

# Decide which sprite to show based on the player movement and if they
# are falling or jumping
func process_sprite(delta: float) -> void:
	if is_animation_busy:
		return
	
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

# If the animation ends and the player was raising the gun then spawn
# the projectile, it also resumes control to the player by reseting
# is_animation_busy to false
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
	if not is_on_floor():
		was_on_floor = false
		velocity.y += gravity
	
	check_and_spawn_dust_particles()
	
	move_and_slide()
