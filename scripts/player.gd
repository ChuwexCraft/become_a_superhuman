extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var stun_timer: Timer = $StunTimer

const SPEED = 200
const JUMP_VELOCITY = -300
const GRAVITY = 700
const WALL_SLIDE_GRAVITY = 300
const WALL_JUMP_FORCE = 300

const DASH_SPEED := 500
const DASH_DURATION := 0.2
const DASH_COOLDOWN := 0.5

var stun = false

var is_dashing : bool = false
var dash_timer : float = 0.0
var dash_cooldown_timer : float = 0.0
var can_dash : bool = true
var dash_direction :int = 0
var has_air_dashed : bool = false

func _physics_process(delta: float) -> void:
	if !stun:# Add the gravity.
		if is_on_floor() or is_on_wall():
			has_air_dashed = false
			#can_dash = true
			#dash_cooldown_timer = 0.0
		
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
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
		if not is_on_floor():
			if is_on_wall() and velocity.y > 0:
				velocity.y += WALL_SLIDE_GRAVITY * delta
			else:
				velocity.y += GRAVITY * delta

		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		if Input.is_action_just_pressed("jump") and is_on_wall():
			velocity.y = JUMP_VELOCITY
			velocity.x = WALL_JUMP_FORCE * get_wall_normal().x
			stun = true
			stun_timer.start()
			
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
				dash_direction = 1
				
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
			
	if velocity.y < 0:
		animated_sprite_2d.play("jump")
	if velocity.y > 0:
		animated_sprite_2d.play("fall")
	
	if is_dashing:
		animated_sprite_2d.play("dash")
	


func _on_stun_timer_timeout() -> void:
	stun = false
