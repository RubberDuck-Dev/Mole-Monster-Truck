extends CharacterBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

const SPEED = 300.0

#handle crouching - shrink collision
var is_crouching:bool = false
var is_pushing:bool = false

const STAND_HEIGHT:float = 128.0
const CROUCH_HEIGHT:float =64.0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("crouch", true):
		crouch()
	else:
		stand()

	if event.is_action_pressed("ui_accept", true):
		is_pushing=true
	else:
		is_pushing=false

func _ready() -> void:
	stand()

func crouch():
	collision_shape.shape.height = CROUCH_HEIGHT	
	collision_shape.position.y = (STAND_HEIGHT - CROUCH_HEIGHT) / 2.0
	
	sprite.scale.y=0.75

func stand():
	collision_shape.shape.height = STAND_HEIGHT
	collision_shape.position.y = 0.0
	sprite.scale.y=1.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
