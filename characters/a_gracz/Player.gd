extends CharacterBody2D

@onready var ui = $"../../CanvasLayer"


@onready var sprite_2d = $Sprite2Dgracz
@onready var sub_viewport = $SubViewport
@onready var model_3d = $SubViewport/Gracz
@onready var anim_player = model_3d.get_node("AnimationPlayer")

@onready var player_hitbox = $playerHitBox
@onready var effects_center = $EffectsCenter
@onready var player_particles = $EffectsCenter/GPUParticles2D




var max_health: int
var current_health: int 






var move_vector = Vector2.DOWN
var move_vector_normalized = Vector2.DOWN
const STANDARD_SPEED = 700 #standardowa i maksymalna;    dla klawiatury
var move_speed_multiplier #korekta dla joysitcka; wolniejsze chodzenie


enum Actions { IDLE, DASH, QUICK_ATTACK, STRONG_ATTACK, DEATH }
var current_action: Actions = Actions.IDLE
var action_direction = Vector2.DOWN


var can_dash = true #do cooldowna
const DASH_SPEED = 3000 #nie może się mnożyć z joystickiem
const DASH_LENGTH = 0.1
const DASH_COOLDOWN = 0.5

var damage
var trafieni: Array = []  # Lista już trafionych przeciwników




func _ready() -> void:
	pass



func _process(delta):
	pass








	#ANIMACJE
	#print($AnimationTree.get("parameters/playback").get_current_node()) # wypisuje obecna animacje
	if move_vector == Vector2.ZERO and current_action == Actions.IDLE:
		anim_player.play("Stanie")
		pass
	elif current_action != Actions.IDLE:
		match current_action:
			Actions.DASH: anim_player.play("Dash")
			Actions.QUICK_ATTACK: anim_player.play("AtakRekaSzybki1")
			Actions.STRONG_ATTACK: anim_player.play("AtakRekaSilny1")
			Actions.DEATH: anim_player.play("Umieranie")
			pass
	else:
		anim_player.play("Chodzenie")
		
		#obracanie
		model_3d.rotation = Vector3(0, -atan2(action_direction.y, action_direction.x), 0)



	sprite_2d.texture = sub_viewport.get_texture()






func _physics_process(delta):
	move_vector.x = (Input.get_action_strength("prawo") - Input.get_action_strength("lewo"))
	move_vector.y = (Input.get_action_strength("dol") - Input.get_action_strength("gora"))
	move_vector_normalized = move_vector.normalized()
	if current_action == Actions.IDLE:
		set_velocity(move_vector_normalized * STANDARD_SPEED) # tu warunek dodac?
	elif current_action != Actions.DASH: # wszystko tlyko nie dash
		set_velocity(Vector2.ZERO)
	#move_speed_multiplier = clamp(move_vector.length(), 0, 1)

	if move_vector != Vector2.ZERO and current_action == Actions.IDLE:
		action_direction = move_vector_normalized


	if current_action == Actions.IDLE:
		#Dash
		if Input.is_action_just_pressed("dash") and can_dash:
			current_action = Actions.DASH
			can_dash = false
			set_velocity(action_direction * DASH_SPEED)
			await get_tree().create_timer(DASH_LENGTH).timeout
			current_action = Actions.IDLE
			await get_tree().create_timer(DASH_COOLDOWN).timeout
			can_dash = true


		#Atak 
		if (Input.is_action_just_pressed("szybki") or Input.is_action_just_pressed("silny")):
			player_hitbox.rotation = action_direction.angle()
			effects_center.rotation = action_direction.angle()
			player_hitbox.monitoring = true
			player_hitbox.monitorable = true

			if Input.is_action_just_pressed("szybki"):
				current_action = Actions.QUICK_ATTACK
				damage = 1
				#await get_tree().create_timer(1).timeout
				player_particles.emitting = true
				await get_tree().create_timer(anim_player.get_animation("AtakRekaSzybki1").length).timeout
			elif Input.is_action_just_pressed("silny"):
				current_action = Actions.STRONG_ATTACK
				damage = 2
				#await get_tree().create_timer(1).timeout
				await get_tree().create_timer(anim_player.get_animation("AtakRekaSilny1").length).timeout

			player_hitbox.monitoring = false
			player_hitbox.monitorable = false
			current_action = Actions.IDLE
			trafieni.clear()
			#przerwanie ataku atakiem przeciwnika




	move_and_slide() #poruszanie się to powoduje















#przyjmowanie obrazen przez gracza
func _on_player_hurt_box_area_entered(area: Area2D) -> void:
	if current_action != Actions.DASH:
		
		if area.get_parent().has_method("after_player_hit"):
			area.get_parent().after_player_hit()
		
		current_health -=1 #każdy możliwy atak ma zadawać nam 1 hp czaisz
		ui.update_hearts(current_health)
		if current_health == 0:
			current_action = Actions.DEATH
			await get_tree().create_timer(anim_player.get_animation("Umieranie").length).timeout
			get_tree().reload_current_scene()
			# obecnie gdy nie ma przypisanej swieczki to nic sie nie dzieje. 
			#rozwiazanie: nie dac graczwoi zginac zanim zapali pierwsza swieczke XD




#zadawanie obrażeń
func _on_player_hit_box_body_entered(body: Node2D) -> void:
	if body.has_method("deal_damage") and not body in trafieni:
		body.deal_damage(damage)  # Wywołanie funkcji zadawania obrażeń
		trafieni.append(body)  # Zapamiętaj, że ten przeciwnik został już trafiony
