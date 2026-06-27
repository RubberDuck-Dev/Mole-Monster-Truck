extends RigidBody2D

#using SPACE - can be pushed (sprite should roll)
# show arrow for push strength

# register when its entered the "exit" area body
	#queue_free when entered and logged as "collected"
	#so that the next level will spawn it in to push further

@export var min_push_strength: float = 25.0
@export var max_push_strength: float = 250.0

var push_strength: float = 0.0
var push_strength_amount: float = 5.0
var push_increment_direction:int = 1 #1 is up, -1 is down

var push_direction:int = 1 #1 is right, -1 is left

var tracking_body:CharacterBody2D

func _ready() -> void:
	hide_labels()

func _process(_delta: float) -> void:
	track_body()

	if tracking_body:
		if tracking_body.is_charging:
			$PushArrow.visible = true
#			print("[track_body] charging..." + str(push_strength))

			push_strength += push_strength_amount * push_increment_direction

			if push_strength >= max_push_strength:
				push_strength=max_push_strength
				push_increment_direction = -1 #decrement
			elif push_strength <= min_push_strength:
				push_strength=min_push_strength
				push_increment_direction = 1 #increment
			
			var visual_strength = snapped(push_strength,25.0)

			$PushArrow/Arrow.scale.x = visual_strength * push_direction * 0.02
			$PushArrow.global_rotation=0.0
			
			if visual_strength < 50:
				$PushArrow/Arrow.modulate=Color.WHITE
			elif visual_strength < 100:
				$PushArrow/Arrow.modulate=Color.GREEN
			elif visual_strength < 150:
				$PushArrow/Arrow.modulate=Color.YELLOW
			elif visual_strength < 200:
				$PushArrow/Arrow.modulate=Color.ORANGE
			elif visual_strength < 250:
				$PushArrow/Arrow.modulate=Color.RED

		else:
			if push_strength > 0.0 and not tracking_body.is_charging:
				$PushArrow.visible=false
				push_ball()
				#self.linear_velocity = Vector2(push_strength * push_direction, 0)
			push_strength = 0.0

func hide_labels()->void:
	$Label.visible = false
	$PushArrow.visible = false

func track_body()->void:
	if tracking_body:
		#track which direction player enters from
		var direction_entered = tracking_body.position.x - self.global_position.x

		if direction_entered < 0:
			push_direction=1
		else:
			push_direction=-1

func push_ball()->void:
	self.apply_impulse(Vector2(push_strength * push_direction, 0), Vector2(1, 0))

func _on_hiding_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		$Label.visible = true
		#$PushArrow.visible = true
		#$PushArrow/Arrow.scale.x *= push_direction
		tracking_body=body
		track_body()

func _on_hiding_area_2d_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		$Label.visible = false
		$PushArrow.visible = false
		tracking_body=null
		push_strength = 0.0
