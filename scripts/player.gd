extends CharacterBody2D
class_name Player
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var stun_timer: Timer = $StunTimer
@onready var coyote_timer : Timer = $CoyoteTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer

#abilities
@export var acquired_dash = false
@export var acquired_double_jump = false
@export var acquired_wall_jump = false

var spawn_pos = Vector2(0,0)
const SPEED = 150
const JUMP_VELOCITY = -250
const GRAVITY = 700
const WALL_SLIDE_GRAVITY = 300
const WALL_JUMP_FORCE = 300

const DASH_SPEED := 400
const DASH_DURATION := 0.2
const DASH_COOLDOWN := 0.5

var stun = false
var can_jump = true
var is_dashing : bool = false
var dash_timer : float = 0.0
var dash_cooldown_timer : float = 0.0
var can_dash : bool = true
var dash_direction :int = 0
var has_air_dashed : bool = false

var can_double_jump : bool = true
var has_double_jumped: bool = false

var last_direction = 1

func _ready() -> void:
	spawn_pos = global_position
func _physics_process(delta: float) -> void:
	if !stun:# Add the gravity.
		if can_jump == false and is_on_floor():
			can_jump = true
		if is_on_floor() or is_on_wall():
			has_air_dashed = false
			if acquired_wall_jump:
				can_double_jump = true
				has_double_jumped = false
				can_dash = true
				dash_cooldown_timer = 0.0
		
		if dash_cooldown_timer > 0:
			dash_cooldown_timer -= delta
			if dash_cooldown_timer <= 0:
				can_dash = true
			
		if is_dashing:
			dash_timer -= delta
			if dash_timer <= 0:
				is_dashing = false
				dash_cooldown_timer = DASH_COOLDOWN
				#dcan_dash = true
			move_and_slide()
			return	
			
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("left", "right")
		if direction != 0:
			last_direction = direction
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
		if not is_on_floor():
			if is_on_wall() and velocity.y > 0:
				if acquired_wall_jump:
					velocity.y += WALL_SLIDE_GRAVITY * delta
				else:
					velocity.y += GRAVITY * delta
			else:
					velocity.y += GRAVITY * delta
		# Handle jump.

			
		if Input.is_action_just_pressed("jump"):
			jump_buffer_timer.start()
		if !jump_buffer_timer.is_stopped() and can_jump:
			velocity.y += JUMP_VELOCITY
			can_jump = false
			can_double_jump = true
			has_double_jumped = false

		if is_on_floor() and can_jump and coyote_timer.is_stopped():
			coyote_timer.start()
		if acquired_wall_jump:
			if Input.is_action_just_pressed("jump") and is_on_wall():
				velocity.y = JUMP_VELOCITY
				velocity.x = WALL_JUMP_FORCE * get_wall_normal().x
				can_double_jump = true
				has_double_jumped = false
				stun = true
				stun_timer.start()
		
		if acquired_double_jump:
			if Input.is_action_just_pressed("jump") \
			and not is_on_floor()\
			and can_double_jump\
			and not has_double_jumped:
				if acquired_wall_jump:
					if not is_on_wall():
						velocity.y = JUMP_VELOCITY
						has_double_jumped = true
				else:
					velocity.y = JUMP_VELOCITY
					has_double_jumped = true
			
		if acquired_dash:
			if Input.is_action_just_pressed("dash") and can_dash:
				if not is_on_floor():
					if has_air_dashed:
						return
					else:
						has_air_dashed = true
					
				is_dashing = true
				dash_timer = DASH_DURATION
				can_dash = false
			
				if direction != 0:
					dash_direction = direction
				else:
					dash_direction = last_direction
					
				velocity.x = dash_direction * DASH_SPEED
				velocity.y = 0
	
	
	update_animation()
	
	move_and_slide()

func update_animation():
	if velocity.x > 0:
		animated_sprite_2d.flip_h = false
	elif velocity.x < 0:
		animated_sprite_2d.flip_h = true
		
	if is_on_floor():
		if abs(velocity.x) > 10:
			animated_sprite_2d.play("run")
		else:
			animated_sprite_2d.play("idle")
			
	if velocity.y:
		if is_on_wall() and acquired_wall_jump:
			animated_sprite_2d.play("climb")
		else:
			animated_sprite_2d.play("jump")
	
			
	
	
	if is_dashing:
		animated_sprite_2d.play("dash")
	


func _on_stun_timer_timeout() -> void:
	stun = false


func _on_hitbox_body_entered(body: Node2D) -> void:
	die()

func die():
	global_position = spawn_pos
	


func _on_checkpoint_collision_area_entered(area: Area2D) -> void:
	print("check!")
	spawn_pos = area.global_position


func _on_coyote_timer_timeout() -> void:
	can_jump = false
