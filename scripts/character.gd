extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const DOUBLE_JUMP_VELOCITY = -300.0
const ACCELERATION = 20.0
const FRICTION = 60.0
const DIVE_VELOCITY = 600.0
const GRAVITY = 1000.0

@onready var anim_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

var direction = ""
var is_crouching = false
var is_diving = false
var has_double_jumped = false
var is_jumping = false
var original_shape_scale
var current_animation = ""

func _ready() -> void:
	original_shape_scale = collision_shape.scale

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_jump()
	handle_double_jump()
	handle_dive()
	handle_crouch()
	handle_movement(delta)
	update_animation()
	move_and_slide()

func apply_gravity(delta: float) -> void:
	if not is_on_floor() and not is_diving:
		velocity.y += GRAVITY * delta
	if is_on_floor():
		has_double_jumped = false
		is_diving = false
		is_jumping = false

func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_crouching:
		velocity.y = JUMP_VELOCITY
		is_jumping = true
		play_animation("jump")

func handle_double_jump() -> void:
	if Input.is_action_just_pressed("jump") and not is_on_floor() and not has_double_jumped and not is_diving:
		velocity.y = DOUBLE_JUMP_VELOCITY
		has_double_jumped = true
		play_animation("jump")
		#play_animation("double_jump")

func handle_dive() -> void:
	if Input.is_action_pressed("down") and not is_on_floor() and not is_diving:
		is_diving = true
		velocity.y = DIVE_VELOCITY
		play_animation("crouch")
		#play_animation("dive")

func handle_crouch() -> void:
	if Input.is_action_pressed("down") and is_on_floor():
		if not is_crouching:
			is_crouching = true
			collision_shape.scale.y = original_shape_scale.y * 0.3
			play_animation("crouch")
	elif is_crouching:
		collision_shape.scale = original_shape_scale
		is_crouching = false

func handle_movement(delta: float) -> void:
	var input_direction = 0.0
	if Input.is_action_pressed("left") and not is_crouching:
		input_direction = -1.0
		direction = "left"
	elif Input.is_action_pressed("right") and not is_crouching:
		input_direction = 1.0
		direction = "right"

	if input_direction != 0.0:
		velocity.x = lerp(velocity.x, input_direction * SPEED, ACCELERATION * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, FRICTION * delta)
		if abs(velocity.x) < 1.0 and is_on_floor() and not is_jumping and not is_crouching:
			velocity.x = 0
			play_animation("idle")

	anim_sprite.flip_h = direction == "left"

@warning_ignore("shadowed_variable_base_class")
func play_animation(name: String) -> void:
	if current_animation != name:
		current_animation = name
		anim_sprite.play(name)

func update_animation() -> void:
	if is_diving:
		play_animation("crouch")
		#play_animation("dive")
	elif is_jumping:
		play_animation("jump")
	elif is_crouching:
		play_animation("crouch")
	elif velocity.x != 0 and is_on_floor():
		play_animation("walk")
	elif velocity.x == 0 and is_on_floor():
		play_animation("idle")
