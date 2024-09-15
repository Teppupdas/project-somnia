extends CharacterBody2D


@onready var animationTree = $AnimationTree
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


var dashing = false
var canDash = true
var dashDirection
const DASH_SPEED = 3000 #nie może się mnożyć z joystickiem
const DASH_LENGTH = 0.5
const DASH_COOLDOWN = 0.5



func _ready():
	healthChanged.emit(currentHealth)



func _process(delta):

	#label1.set_text("FPS: " + str(Engine.get_frames_per_second()))
	label1.set_text("Życie: " + str(currentHealth))

	if canDash:
		label2.text = "+"
	else:
		label2.text = " "







	#ANIMACJE
	if moveVector == Vector2.ZERO and !dashing:
		animationMode.travel("Stanie")
	elif dashing:
		animationMode.travel("Dashowanie")
	else:
		animationMode.travel("Chodzenie")
		animationTree.set("parameters/Stanie/blend_position", Vector2(moveVector.normalized().x, -moveVector.normalized().y))
		animationTree.set("parameters/Chodzenie/blend_position", Vector2(moveVector.normalized().x, -moveVector.normalized().y))
		animationTree.set("parameters/Dashowanie/blend_position", Vector2(moveVector.normalized().x, -moveVector.normalized().y))













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
			# i sprawdzić w Hades na padzie jak prędkość poruszania wpływa na animacje!
		set_velocity(dashDirection.normalized() * currentMoveSpeed)
		move_and_slide()
	else:
		set_velocity(moveVector.normalized() * currentMoveSpeed * moveSpeedMultiplier)
		move_and_slide()
		
		#move_and_collide(moveVector.normalized() * currentMoveSpeed * moveSpeedMultiplier / 50)




func _on_player_hurt_box_area_entered(area: Area2D) -> void:
	if area.name == "hitBox":
		area.get_parent().queue_free()
		currentHealth -=1
		if currentHealth == 0:
			currentHealth = maxHealth
		healthChanged.emit(currentHealth)
