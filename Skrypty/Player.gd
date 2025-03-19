extends CharacterBody2D

@onready var UI = $"../../CanvasLayer"

@onready var animationTree = $AnimationTree
@onready var animationPlayer = $AnimationPlayer
@onready var animationMode = animationTree.get("parameters/playback")

@onready var label1 = $Label1
@onready var label2 = $Label2


var maxHealth: int
var currentHealth: int 






var moveVector = Vector2.DOWN
var moveVectorNormalized = Vector2.DOWN
const STANDARD_SPEED = 800 #standardowa i maksymalna;    dla klawiatury
var moveSpeedMultiplier #korekta dla joysitcka; wolniejsze chodzenie


enum Action { IDLE, DASH, QUICK_ATTACK, STRONG_ATTACK, DEATH }
var action: Action = Action.IDLE
var actionDirection = Vector2.DOWN


var canDash = true #do cooldowna
const DASH_SPEED = 3000 #nie może się mnożyć z joystickiem
const DASH_LENGTH = 0.2
const DASH_COOLDOWN = 0.5

@onready var playerHitBox = $playerHitBox
var damage
var trafieni: Array = []  # Lista już trafionych przeciwników



func _ready():
	pass




func _process(delta):

	label1.set_text("FPS: " + str(Engine.get_frames_per_second()))
	#label1.set_text("maxŻycie: " + str(maxHealth))

	if canDash:
		label2.text = "+"
	else:
		label2.text = " "







	#ANIMACJE
	if moveVector == Vector2.ZERO and action == Action.IDLE:
		animationMode.travel("Stanie")
	elif action != Action.IDLE:
		match action:
			Action.DASH: animationMode.travel("Dashowanie")
			Action.QUICK_ATTACK: animationMode.travel("AtakRekaSzybki1")
			Action.STRONG_ATTACK: animationMode.travel("AtakRekaSilny1")
			Action.DEATH: animationMode.travel("Umieranie")
			
	else:
		animationMode.travel("Chodzenie")
		var blendPosition = Vector2(actionDirection.x, -actionDirection.y) #to musi miec y na minusie bo jest w innym kierunku w blend posiition niz w swiecie gry
		animationTree.set("parameters/Stanie/blend_position", blendPosition)
		animationTree.set("parameters/Chodzenie/blend_position", blendPosition)
		animationTree.set("parameters/Dashowanie/blend_position", blendPosition)
		animationTree.set("parameters/AtakRekaSzybki1/blend_position", blendPosition)
		animationTree.set("parameters/AtakRekaSilny1/blend_position", blendPosition)




func _physics_process(delta):
	moveVector.x = (Input.get_action_strength("prawo") - Input.get_action_strength("lewo"))
	moveVector.y = (Input.get_action_strength("dol") - Input.get_action_strength("gora"))
	moveVectorNormalized = moveVector.normalized()
	if action == Action.IDLE:
		set_velocity(moveVectorNormalized * STANDARD_SPEED) # tu warunek dodac?
	elif action != Action.DASH: # wszystko tlyko nie dash
		set_velocity(Vector2.ZERO)
	#moveSpeedMultiplier = clamp(moveVector.length(), 0, 1)

	if moveVector != Vector2.ZERO and action == Action.IDLE:
		actionDirection = moveVectorNormalized


	if action == Action.IDLE:
		#Dash
		if Input.is_action_just_pressed("dash") and canDash:
			action = Action.DASH
			canDash = false
			set_velocity(actionDirection * DASH_SPEED)
			await get_tree().create_timer(DASH_LENGTH).timeout
			action = Action.IDLE
			await get_tree().create_timer(DASH_COOLDOWN).timeout
			canDash = true


		#Atak 
		if (Input.is_action_just_pressed("szybki") or Input.is_action_just_pressed("silny")):
			#playerHitBox.global_position = global_position + Vector2(0, 0) + actionDirection.rotated(PI / 2) * 0 + actionDirection * 120
			playerHitBox.rotation = actionDirection.angle()
			playerHitBox.monitoring = true
			playerHitBox.monitorable = true

			if Input.is_action_just_pressed("szybki"):
				action = Action.QUICK_ATTACK
				damage = 1
				#await get_tree().create_timer(1).timeout
				await get_tree().create_timer(animationPlayer.get_animation("Atak_Reka_Szybki_1_E").length).timeout
			elif Input.is_action_just_pressed("silny"):
				action = Action.STRONG_ATTACK
				damage = 2
				#await get_tree().create_timer(1).timeout
				await get_tree().create_timer(animationPlayer.get_animation("Atak_Reka_Silny_1_E").length).timeout

			playerHitBox.monitoring = false
			playerHitBox.monitorable = false
			action = Action.IDLE
			trafieni.clear()
			#przerwanie ataku atakiem przeciwnika




	move_and_slide() #poruszanie się to powoduje



func _on_player_hurt_box_area_entered(area: Area2D) -> void:
	if action != Action.DASH:
		area.get_parent().queue_free() # usuwa to co zadaje obrazenia
		currentHealth -=1 #każdy możliwy atak ma zadawać nam 1 hp czaisz
		UI.updateHearts(currentHealth)
		if currentHealth == 0:
			action = Action.DEATH
			await get_tree().create_timer(animationPlayer.get_animation("Umieranie").length).timeout
			get_tree().reload_current_scene()
			# obecnie gdy nie ma przypisanej swieczki to nic sie nie dzieje. 
			#rozwiazanie: nie dac graczwoi zginac zanim zapali pierwsza swieczke


func _on_player_hit_box_body_entered(body: Node2D) -> void:
	if body.has_method("dealDamage") and not body in trafieni:
		body.dealDamage(damage)  # Wywołanie funkcji zadawania obrażeń
		trafieni.append(body)  # Zapamiętaj, że ten przeciwnik został już trafiony
