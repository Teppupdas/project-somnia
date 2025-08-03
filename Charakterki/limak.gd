extends CharacterBody2D
@onready var player = $"../Gracz"

@onready var sprite2D = $Sprite2D
@onready var navAgent = $NavigationAgent2D
@onready var subViewport = $SubViewport
@onready var model3D = $SubViewport/Limak
@onready var animPlayer = model3D.get_node("AnimationPlayer")
@onready var rushHitBox = $rushHitBox
@onready var tailwhipHitBox = $tailwhipHitBox


var health = 20

enum Action { MOVE, RUSH_WINDUP, RUSH, RUSH_RETURN, RECOVERY, 
TAIL_WHIP_WINDUP_L, TAIL_WHIP_L, 
TAIL_WHIP_WINDUP_R, TAIL_WHIP_R }
var action: Action = Action.MOVE
var actionDirection = Vector2.ZERO
var lookAtPlayer
var triggeredByPlayer

const STANDARD_SPEED = 400
const TURN_SPEED = 3.0

var canRush = true #do cooldowna
const RUSH_SPEED = 2000
const RUSH_COOLDOWN = 2 ### wyjebac cooldowny<>>>>>????? 
const RECOVERY_TIME = 2






func _process(delta: float) -> void:
	sprite2D.texture = subViewport.get_texture()
	model3D.rotation = Vector3(0, -atan2(actionDirection.y, actionDirection.x), 0)
	animPlayer.play(Action.find_key(action))







func _physics_process(delta):
	var random = randi_range(0,1000)
	var distanceToPlayer = global_position.distance_to(player.global_position)
	var angleToPlayer = abs(actionDirection.angle_to((player.global_position - global_position).normalized()))
	
	
	#movement
	if action == Action.MOVE:
		if distanceToPlayer > 213.7:
			navAgent.target_position = player.global_position
			
			
			#płynny obrót w kierunku path
			var target_angle = (navAgent.get_next_path_position() - global_position).angle()
			var current_angle = actionDirection.angle()
			var new_angle = lerp_angle(current_angle, target_angle, TURN_SPEED * delta)
			actionDirection = Vector2.RIGHT.rotated(new_angle)
			
			set_velocity(actionDirection * STANDARD_SPEED)
			
		else:
			pass
			#print("dystans do gracza:" + str(distanceToPlayer))





	#RUSH
	if canRush and distanceToPlayer < 1300 and rushConditions(navAgent.get_current_navigation_path(), distanceToPlayer, angleToPlayer):
		print("rush")
		
		#przygotowanie 
		action = Action.RUSH_WINDUP
		set_velocity(Vector2.ZERO)
		canRush = false
		var rushTime = distanceToPlayer / RUSH_SPEED
		await get_tree().create_timer(animPlayer.get_animation("RUSH_WINDUP").length).timeout
	
		#atak
		action = Action.RUSH
		rushHitBox.rotation = actionDirection.angle()
		rushHitBox.monitorable = true
		set_velocity(actionDirection * RUSH_SPEED)
		await get_tree().create_timer(rushTime).timeout
	
		#powrót
		action = Action.RUSH_RETURN
		rushHitBox.monitorable = false
		set_velocity(Vector2.ZERO)
		await get_tree().create_timer(animPlayer.get_animation("RUSH_RETURN").length).timeout
		
		
		#recovery
		action = Action.RECOVERY
		await get_tree().create_timer(RECOVERY_TIME).timeout
		
		
		
		
		
		
		
		
		
		#atak jeśli gracz blisko
		var currentDistanceToPlayer = global_position.distance_to(player.global_position)
		var directionToPlayer = (player.global_position - global_position).normalized()
		if currentDistanceToPlayer < 213.7:
			print("ogokn")
			#obrót
			#czas windup zalezny od kata do gracza
			var targetDir = (-directionToPlayer).normalized()
			var angle_diff = actionDirection.angle_to(targetDir) # od -PI do PI
			var windup_ratio = abs(angle_diff) / TAU
			# wybór animacji zależnie od kierunku obrotu
			var windupAnim = "TAIL_WHIP_WINDUP_L" if angle_diff < 0 else "TAIL_WHIP_WINDUP_R"
			var biczAnim = "TAIL_WHIP_L" if angle_diff < 0 else "TAIL_WHIP_R"


			var windup_time = animPlayer.get_animation(windupAnim).length * windup_ratio
			action = Action[windupAnim]
			await get_tree().create_timer(windup_time).timeout



			
			
			
			#cios bicz
			tailwhipHitBox.rotation = targetDir.angle()
			tailwhipHitBox.monitorable = true
			actionDirection = targetDir
			
			action = Action[biczAnim]
			await get_tree().create_timer(animPlayer.get_animation(biczAnim).length).timeout
			tailwhipHitBox.monitorable = false
		
		
		
		
		
		
		
		
		
		set_velocity(actionDirection * STANDARD_SPEED)
		action = Action.MOVE
		
		#coolodwn
		await get_tree().create_timer(RUSH_COOLDOWN).timeout
		canRush = true
		
		










	move_and_slide() #poruszanie się to powoduje



#func rush():











func rushConditions(path, distanceToPlayer, angleToPlayer):
	#to sprawdza czy droga wolna dla rush; czy przeszkód nie ma
	var pathLength = 0.0
	for i in range(path.size() - 1):
		pathLength += path[i].distance_to(path[i + 1])
	var direct_distance = path[0].distance_to(path[-1])
	
	#to sprawdza czy slimak jest w kierunku gracza, drugi warunek ponizje
	


	return pathLength == distanceToPlayer and angleToPlayer < deg_to_rad(5)



func afterPlayerHit():
	rushHitBox.monitorable = false
	tailwhipHitBox.monitorable = false



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
