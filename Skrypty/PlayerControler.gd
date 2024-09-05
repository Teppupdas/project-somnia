extends CharacterBody2D

#@onready var animatedSprite = $Sprite2D
#@onready var animationPlayer = $AnimationPlayer
#@onready var animationTree = $AnimationTree

@onready var label1 = $Label1
@onready var label2 = $Label2





var moveVector = Vector2.ZERO
var currentMoveSpeed = STANDARD_SPEED
const STANDARD_SPEED = 800 #standardowa i maksymalna;    dla klawiatury
var moveSpeedMultiplier #korekta dla joysitcka; wolniejsze chodzenie


var dashing = false
var canDash = true
var dashDirection
const DASH_SPEED = 3000 #nie może się mnożyć z joystickiem
const DASH_LENGTH = 0.2
const DASH_COOLDOWN = 1



func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)



func _process(delta):

	label1.set_text("FPS: " + str(Engine.get_frames_per_second()))

	if canDash:
		label2.text = "+"
	else:
		label2.text = " "








	#if moveVector == Vector2.ZERO:     #gdy to animacja dasha sie pierdoli.........................trzeba manager animacji zrobic
		#animationTree["parameters/Tranzycja/transition_request"] = "Stanie"  #zmiana animacji na stanie
	#elif dashing:
		#animationTree["parameters/Tranzycja/transition_request"] = "Daszowanie"  #zmiana animacji na daszowanie
		#animationTree.set("parameters/DashArkusze/blend_position", Vector2(dashDirection.normalized().x, -dashDirection.normalized().y))    #ustawia kierunek animacji
	#else:
		#animationTree["parameters/Tranzycja/transition_request"] = "Poruszanie"  #zmiana animacji na chodzenie
		#animationTree.set("parameters/PoruszanieArkusze/blend_position", Vector2(moveVector.normalized().x, -moveVector.normalized().y))    #ustawia kierunek animacji



		










	



func _physics_process(delta):
	moveVector.x = (Input.get_action_strength("prawo") - Input.get_action_strength("lewo"))
	moveVector.y = (Input.get_action_strength("dol") - Input.get_action_strength("gora"))

	moveSpeedMultiplier = clamp(moveVector.length(), 0, 1)

	
	
	#Dash
	if moveVector != Vector2.ZERO and Input.is_action_just_pressed("dash") and canDash:
		dashing = true
		canDash = false
		dashDirection = moveVector
		currentMoveSpeed = DASH_SPEED
		await get_tree().create_timer(DASH_LENGTH).timeout
		dashing = false
		currentMoveSpeed = STANDARD_SPEED
		await get_tree().create_timer(DASH_COOLDOWN).timeout
		canDash = true




	if dashing:
		#if moveVector == Vector2.ZERO:
			#zatrzymać daszowanie? Sprawdzić jak jest w Hades 
		set_velocity(dashDirection.normalized() * currentMoveSpeed)
		move_and_slide()
	else:
		set_velocity(moveVector.normalized() * currentMoveSpeed * moveSpeedMultiplier)
		move_and_slide()



	
