extends CharacterBody2D

var direction = Vector2.ZERO
var speed = 2137/20
func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


 

func _physics_process(delta: float) -> void:
	var motion = direction * speed * delta
	var collision = move_and_collide(motion)
	if collision:
		queue_free()



func after_player_hit():
	queue_free()
