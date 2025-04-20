extends CharacterBody2D
@onready var animationTree = $AnimationTree
@onready var animationPlayer = $AnimationPlayer
@onready var animationMode = animationTree.get("parameters/playback")

@onready var player = $"../Gracz"


var health = 5

enum Action { MOVE, WINDUP, RUSH }
var action: Action = Action.MOVE
var actionDirection
var distanceToPlayer
var random = 0
var lookAtPlayer
var triggeredByPlayer

const STANDARD_SPEED = 400

var canRush = true #do cooldowna
const RUSH_SPEED = 2500
const RUSH_LENGTH = 0.3
const RUSH_COOLDOWN = 2 ### wyjebac cooldowny<>>>>>????? 






func _process(delta: float) -> void:
	
	
	
	

	
	#print($AnimationTree.get("parameters/playback").get_current_node()) # wypisuje obecna animacje
	
	#ANIMACJE
	match action:
		Action.MOVE: animationMode.travel("Move")
		Action.WINDUP: animationMode.travel("Windup")
		Action.RUSH: animationMode.travel("Rush")
		
	var blendPosition = Vector2(actionDirection.x, -actionDirection.y) #to musi miec y na minusie bo jest w innym kierunku w blend posiition niz w swiecie gry
	animationTree.set("parameters/Move/blend_position", actionDirection.x)
	animationTree.set("parameters/Windup/blend_position", actionDirection.x)
	animationTree.set("parameters/Rush/blend_position", actionDirection.x)

	#animationTree.set("parameters/Attack/blend_position", blendPosition)
	#animationTree.set("parameters/Windup/blend_position", blendPosition)
	#animationTree.set("parameters/Stay/blend_position", blendPosition)








func _physics_process(delta):
	random = randi_range(0,1000)
	distanceToPlayer = global_position.distance_to(player.global_position)
	#print(distanceToPlayer)
	
	
	#patrz w kierunku gracza
	if action == Action.MOVE or Action.WINDUP:
		actionDirection = (player.global_position - global_position).normalized()
	#idz w kierunku action direction
	if action == Action.MOVE:
		set_velocity(actionDirection * STANDARD_SPEED)

	
	
	
	
	
	
	
	#RUSH
	if canRush and distanceToPlayer < 300 and random < 10:
		print("atakduchola")
		
		#przygotowanie 
		action = Action.WINDUP
		set_velocity(actionDirection * 0)
		canRush = false
		await get_tree().create_timer(0.5).timeout
	
		#atak
		action = Action.RUSH
		set_velocity(actionDirection * RUSH_SPEED)
		await get_tree().create_timer(RUSH_LENGTH).timeout
	
		#powrót
		action = Action.MOVE
		set_velocity(actionDirection * STANDARD_SPEED)
		
		
		#coolodwn
		await get_tree().create_timer(RUSH_COOLDOWN).timeout
		canRush = true

	move_and_slide() #poruszanie się to powoduje





#func rush():







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
