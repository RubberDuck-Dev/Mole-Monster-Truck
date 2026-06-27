extends Area2D

#using SPACE - can be pushed (and sprite rolls)
# show an arrow for gauging the push strength

# register when its entered the "exit" area body
	#queue_free when entered and logged as "collected"
	#so that the next level will spawn it in to push further

var tracking_body:CharacterBody2D

func _ready() -> void:
	hide_labels()

func _process(_delta: float) -> void:
	track_body()

func hide_labels()->void:
	$Label.visible = false
	$PushArrow.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		$Label.visible = true
		$PushArrow.visible = true
		tracking_body=body
		track_body()
		
func track_body()->void:
	if tracking_body:
		#track which direction they are entering from
		var direction_entered = tracking_body.position.x - self.global_position.x
		
		if direction_entered < 0:
			$PushArrow/ArrowLeft.visible = false
			$PushArrow/ArrowRight.visible = true
		else:
			$PushArrow/ArrowLeft.visible = true
			$PushArrow/ArrowRight.visible = false
		
func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		$Label.visible = false
		$PushArrow.visible = false
		tracking_body=null
