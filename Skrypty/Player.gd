extends CharacterBody2D


@onready var animationTree = $AnimationTree
@onready var animationPlayer = $AnimationPlayer
@onready var animationMode = animationTree.get("parameters/playback")

@onready var label1 = $Label1
@onready var label2 = $Label2


@export var maxHealth = 20
@onready var currentHealth: int = maxHealth
signal healthChanged







var moveVector = Vector2.ZERO
const STANDARD_SPEED = 800 #standardowa i maksymalna;    dla klawiatury
var currentMoveSpeed = STANDARD_SPEED
var moveSpeedMultiplier #korekta dla joysitcka; wolniejsze chodzenie



var actionDirection

var dashing = false
var canDash = true
const DASH_SPEED = 3000 #nie może się mnożyć z joystickiem
const DASH_LENGTH = 0.5
const DASH_COOLDOWN = 0.5

var attack = 0
var canAttack = true



func _ready():
	healthChanged.emit(currentHealth)



func _process(delta):

	label1.set_text("FPS: " + str(Engine.get_frames_per_second()))
	#label1.set_text("Życie: " + str(currentHealth))

	if canDash:
		label2.text = "+"
	else:
		label2.text = " "







	#ANIMACJE
	if moveVector == Vector2.ZERO and !dashing and attack == 0:
		animationMode.travel("Stanie")
	elif dashing:
		animationMode.travel("Dashowanie")
	elif attack != 0:
		match attack:
			1: animationMode.travel("AtakRekaSzybki1")
			2: animationMode.travel("AtakRekaSilny1")
	else:
		animationMode.travel("Chodzenie")
		var blendPosition = Vector2(moveVector.normalized().x, -moveVector.normalized().y)
		animationTree.set("parameters/Stanie/blend_position", blendPosition)
		animationTree.set("parameters/Chodzenie/blend_position", blendPosition)
		animationTree.set("parameters/Dashowanie/blend_position", blendPosition)
		animationTree.set("parameters/AtakRekaSzybki1/blend_position", blendPosition)
		animationTree.set("parameters/AtakRekaSilny1/blend_position", blendPosition)




func _physics_process(delta):
	moveVector.x = (Input.get_action_strength("prawo") - Input.get_action_strength("lewo"))
	moveVector.y = (Input.get_action_strength("dol") - Input.get_action_strength("gora"))

	moveSpeedMultiplier = clamp(moveVector.length(), 0, 1)





	#Dash aktywacja
	if Input.is_action_just_pressed("dash") and canDash and moveVector != Vector2.ZERO and attack == 0:
		dashing = true
		canDash = false
		actionDirection = moveVector
		currentMoveSpeed = DASH_SPEED
		await get_tree().create_timer(DASH_LENGTH).timeout
		dashing = false
		currentMoveSpeed = STANDARD_SPEED
		await get_tree().create_timer(DASH_COOLDOWN).timeout
		canDash = true


	#Atak szybki aktywacja
	if Input.is_action_just_pressed("szybki") and !dashing and attack == 0:
		attack = 1
		canAttack = false
		actionDirection = moveVector
		currentMoveSpeed = 0
		await get_tree().create_timer(animationPlayer.get_animation("Atak_Reka_Szybki_1_E").length).timeout
		attack = 0
		currentMoveSpeed = STANDARD_SPEED
		#przerwanie ataku atakiem przeciwnika

	#Atak silny aktywacja
	if Input.is_action_just_pressed("silny") and !dashing and attack == 0:
		attack = 2
		canAttack = false
		actionDirection = moveVector
		currentMoveSpeed = 0
		await get_tree().create_timer(animationPlayer.get_animation("Atak_Reka_Silny_1_E").length).timeout
		attack = 0
		currentMoveSpeed = STANDARD_SPEED
		#przerwanie ataku atakiem przeciwnika





	if dashing:
		#if moveVector == Vector2.ZERO:
			#zatrzymać daszowanie? Sprawdzić jak jest w Hades 
			# i sprawdzić w Hades na padzie jak prędkość poruszania wpływa na animacje!
		set_velocity(actionDirection.normalized() * currentMoveSpeed)  #ustawia prędkość na daszowanie
	else:
		set_velocity(moveVector.normalized() * currentMoveSpeed * moveSpeedMultiplier) #ustawia prędkość na standardową
	
	
	move_and_slide() #poruszanie się to powoduje



func _on_player_hurt_box_area_entered(area: Area2D) -> void:
	if area.name == "hitBox" and !dashing:
		area.get_parent().queue_free()
		currentHealth -=1
		if currentHealth == 0:
			currentHealth = maxHealth
		healthChanged.emit(currentHealth)
