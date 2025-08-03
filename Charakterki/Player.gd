extends CharacterBody2D

@onready var UI = $"../../CanvasLayer"


@onready var sprite2D = $Sprite2Dgracz
@onready var subViewport = $SubViewport
@onready var model3D = $SubViewport/Gracz
@onready var animPlayer = model3D.get_node("AnimationPlayer")

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
const DASH_LENGTH = 0.1
const DASH_COOLDOWN = 0.5

@onready var playerHitBox = $playerHitBox
var damage
var trafieni: Array = []  # Lista już trafionych przeciwników




func _ready() -> void:
	pass



func _process(delta):
	
	sprite2D.texture = subViewport.get_texture()

	label1.set_text("FPS: " + str(Engine.get_frames_per_second()))
	#label1.set_text("maxŻycie: " + str(maxHealth))

	if canDash:
		label2.text = "+"
	else:
		label2.text = " "







	#ANIMACJE
	#print($AnimationTree.get("parameters/playback").get_current_node()) # wypisuje obecna animacje
	if moveVector == Vector2.ZERO and action == Action.IDLE:
		animPlayer.play("Stanie")
		pass
	elif action != Action.IDLE:
		match action:
			Action.DASH: animPlayer.play("Dash")
			Action.QUICK_ATTACK: animPlayer.play("AtakRekaSzybki1")
			Action.STRONG_ATTACK: animPlayer.play("AtakRekaSilny1")
			Action.DEATH: animPlayer.play("Umieranie")
			pass
	else:
		animPlayer.play("Chodzenie")
		
		#obracanie
		model3D.rotation = Vector3(0, -atan2(actionDirection.y, actionDirection.x), 0)





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
			playerHitBox.rotation = actionDirection.angle()
			playerHitBox.monitoring = true
			playerHitBox.monitorable = true

			if Input.is_action_just_pressed("szybki"):
				action = Action.QUICK_ATTACK
				damage = 1
				#await get_tree().create_timer(1).timeout
				await get_tree().create_timer(animPlayer.get_animation("AtakRekaSzybki1").length).timeout
			elif Input.is_action_just_pressed("silny"):
				action = Action.STRONG_ATTACK
				damage = 2
				#await get_tree().create_timer(1).timeout
				await get_tree().create_timer(animPlayer.get_animation("AtakRekaSilny1").length).timeout

			playerHitBox.monitoring = false
			playerHitBox.monitorable = false
			action = Action.IDLE
			trafieni.clear()
			#przerwanie ataku atakiem przeciwnika




	move_and_slide() #poruszanie się to powoduje


#przyjmowanie obrażeń
func _on_player_hurt_box_area_entered(area: Area2D) -> void:
	if action != Action.DASH:
		
		#area.get_parent().queue_free() # usuwa to co zadaje obrazenia
		if area.get_parent().has_method("afterPlayerHit"):
			area.get_parent().afterPlayerHit()
		
		currentHealth -=1 #każdy możliwy atak ma zadawać nam 1 hp czaisz
		UI.updateHearts(currentHealth)
		if currentHealth == 0:
			action = Action.DEATH
			await get_tree().create_timer(animPlayer.get_animation("Umieranie").length).timeout
			get_tree().reload_current_scene()
			# obecnie gdy nie ma przypisanej swieczki to nic sie nie dzieje. 
			#rozwiazanie: nie dac graczwoi zginac zanim zapali pierwsza swieczke

#zadawanie obrażeń
func _on_player_hit_box_body_entered(body: Node2D) -> void:
	if body.has_method("dealDamage") and not body in trafieni:
		body.dealDamage(damage)  # Wywołanie funkcji zadawania obrażeń
		trafieni.append(body)  # Zapamiętaj, że ten przeciwnik został już trafiony
