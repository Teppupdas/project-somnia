extends CharacterBody2D


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass



#func _physics_process(delta):
	#position.x -= 600 * delta



var direction: Vector2 = Vector2(-1, 0).normalized() 

func _physics_process(delta: float) -> void:
	var motion = direction * 600 * delta
	var collision = move_and_collide(motion)
	if collision:
		queue_free()
