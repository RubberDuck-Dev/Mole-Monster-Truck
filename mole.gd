extends CharacterBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

const WALK_SPEED = 400.0
const CROUCH_SPEED = 200.0

#handle crouching - shrink collision
var is_crouching:bool = false
var is_pushing:bool = false
var is_charging:bool = false

const STAND_HEIGHT:float = 128.0
const CROUCH_HEIGHT:float= 64.0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("crouch", true):
		crouch()
	else:
		stand()

	if event.is_action_pressed("ui_accept", true):
		is_pushing=true
		is_charging=true
	else:
		is_pushing=false
		is_charging=false

func _ready() -> void:
	stand()

func crouch():
	is_crouching=true
	collision_shape.shape.height = CROUCH_HEIGHT	
	collision_shape.position.y = (STAND_HEIGHT - CROUCH_HEIGHT) / 2.0
	
	sprite.scale.y=0.75

func stand():
	is_crouching=false
	collision_shape.shape.height = STAND_HEIGHT
	collision_shape.position.y = 0.0
	sprite.scale.y=1.0

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity += get_gravity() * delta

	var curr_speed = CROUCH_SPEED if is_crouching else WALK_SPEED
	# Get the input direction and handle movement
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * curr_speed
	else:
		velocity.x = move_toward(velocity.x, 0, curr_speed)

	move_and_slide()
