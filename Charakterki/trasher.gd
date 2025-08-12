extends CharacterBody2D
@onready var player = $"../Gracz"

@onready var sprite2D = $Sprite2D
@onready var navAgent = $NavigationAgent2D
@onready var subViewport = $SubViewport
@onready var model3D = $SubViewport/Trasher
@onready var animPlayer = model3D.get_node("AnimationPlayer")

@onready var hitbox = $Hitbox


var health = 1

enum Action { RUN }
var action: Action = Action.RUN
var actionDirection = Vector2.ZERO

const STANDARD_SPEED = 900
const TURN_SPEED = 7.0








func _process(delta: float) -> void:
	model3D.rotation = Vector3(0, -atan2(actionDirection.y, actionDirection.x), 0)
	animPlayer.play(Action.find_key(action))
	sprite2D.texture = subViewport.get_texture()







func _physics_process(delta):
	var random = randi_range(0,1000)
	var distance_to_player = global_position.distance_to(player.global_position)
	
	
	navAgent.target_position = player.global_position
	
	
	#płynny obrót w kierunku path
	var target_angle = (navAgent.get_next_path_position() - global_position).angle()
	var current_angle = actionDirection.angle()
	var new_angle = lerp_angle(current_angle, target_angle, TURN_SPEED * delta)
	actionDirection = Vector2.RIGHT.rotated(new_angle)
	
	
	hitbox.rotation = actionDirection.angle()
	
	set_velocity(actionDirection * STANDARD_SPEED)
	move_and_slide() #poruszanie się to powoduje







#wlacza lub wylacza collidery atakow przeciwnikow
func set_colliders_enabled(area: Area2D, enabled: bool) -> void:
	for collider in area.get_children():
		collider.disabled = not enabled







func afterPlayerHit():
	set_colliders_enabled(hitbox, false)
	dealDamage(1)



func dealDamage(damage):
	health -= damage
	
	if health <= 0:
		#tu jakaś animacja umierania najpierw
		queue_free()
	else: #migniecie na czerwono
		#jakiś dzwięk tu puścić
		var tween = create_tween()
		tween.tween_property($Sprite2D, "modulate", Color.RED, 0.07)
		tween.tween_property($Sprite2D, "modulate", Color.WHITE, 0.07)
