extends CharacterBody2D
@onready var player = $"../Gracz"

@onready var sprite_2d = $Sprite2D
@onready var nav_agent = $NavigationAgent2D
@onready var sub_viewport = $SubViewport
@onready var model_3d = $SubViewport/Limak
@onready var anim_player = model_3d.get_node("AnimationPlayer")

@onready var rush_hitbox = $rushHitBox
@onready var tailwhip_hitbox = $tailwhipHitBox


var health = 20

enum Actions { MOVE, RUSH_WINDUP, RUSH, RUSH_RETURN, RECOVERY, 
TAIL_WHIP_WINDUP_L, TAIL_WHIP_L, 
TAIL_WHIP_WINDUP_R, TAIL_WHIP_R }
var current_action: Actions = Actions.MOVE
var action_direction = Vector2.ZERO
var look_at_player
var triggered_by_player

const STANDARD_SPEED = 400
const TURN_SPEED = 3.0

var can_rush = true #do cooldowna
const RUSH_SPEED = 2000
const RUSH_COOLDOWN = 2 ### wyjebac cooldowny<>>>>>????? 
const RECOVERY_TIME = 0.3






func _process(delta: float) -> void:
	model_3d.rotation = Vector3(0, -atan2(action_direction.y, action_direction.x), 0)
	anim_player.play(Actions.find_key(current_action))
	sprite_2d.texture = sub_viewport.get_texture()







func _physics_process(delta):
	var random = randi_range(0,1000)
	var distance_to_player = global_position.distance_to(player.global_position)
	var angle_to_player = abs(action_direction.angle_to((player.global_position - global_position).normalized()))
	
	
	#movement
	if current_action == Actions.MOVE:
		if distance_to_player > 213.7:
			nav_agent.target_position = player.global_position
			
			
			#płynny obrót w kierunku path
			var target_angle = (nav_agent.get_next_path_position() - global_position).angle()
			var current_angle = action_direction.angle()
			var new_angle = lerp_angle(current_angle, target_angle, TURN_SPEED * delta)
			action_direction = Vector2.RIGHT.rotated(new_angle)
			
			set_velocity(action_direction * STANDARD_SPEED)
			
			if can_rush and distance_to_player < 1300 and rush_conditions(nav_agent.get_current_navigation_path(), distance_to_player, angle_to_player):
				rush(distance_to_player)
			
			
		else:
			tail_whip()






	move_and_slide() #poruszanie się to powoduje



func rush(distance_to_player):
	#przygotowanie 
	current_action = Actions.RUSH_WINDUP
	set_velocity(Vector2.ZERO)
	can_rush = false
	var rush_time = distance_to_player / RUSH_SPEED
	await get_tree().create_timer(anim_player.get_animation("RUSH_WINDUP").length).timeout

	#atak
	current_action = Actions.RUSH
	rush_hitbox.rotation = action_direction.angle()
	set_colliders_enabled(rush_hitbox, true)
	set_velocity(action_direction * RUSH_SPEED)
	await get_tree().create_timer(rush_time).timeout

	#powrót
	current_action = Actions.RUSH_RETURN
	set_colliders_enabled(rush_hitbox, false)
	set_velocity(Vector2.ZERO)
	await get_tree().create_timer(anim_player.get_animation("RUSH_RETURN").length).timeout
	
	
	#recovery
	current_action = Actions.RECOVERY
	await get_tree().create_timer(RECOVERY_TIME).timeout
		
		
		
		
	#tail_whip jeśli gracz blisko
	var current_distance_to_player = global_position.distance_to(player.global_position)
	if current_distance_to_player < 213.7:
		tail_whip()
		
		
		
		
	set_velocity(action_direction * STANDARD_SPEED)
	current_action = Actions.MOVE
	#coolodwn
	await get_tree().create_timer(RUSH_COOLDOWN).timeout
	can_rush = true
		
		



func tail_whip():	
	#przygotowanie 
	set_velocity(Vector2.ZERO)
	#czas windup zalezny od kata do gracza
	var target_dir = -(player.global_position - global_position).normalized()
	var angle_diff = action_direction.angle_to(target_dir) # od -PI do PI
	var windup_ratio = abs(angle_diff) / TAU
	# wybór animacji zależnie od kierunku obrotu
	var windup_anim = "TAIL_WHIP_WINDUP_L" if angle_diff < 0 else "TAIL_WHIP_WINDUP_R"
	var bicz_anim = "TAIL_WHIP_L" if angle_diff < 0 else "TAIL_WHIP_R"
	#czas windup zalezny od kata do gracza
	var windup_time = anim_player.get_animation(windup_anim).length * windup_ratio
	current_action = Actions[windup_anim]
	await get_tree().create_timer(windup_time).timeout


	
	#cios bicz
	tailwhip_hitbox.rotation = target_dir.angle()
	set_colliders_enabled(tailwhip_hitbox, true)
	action_direction = target_dir
	
	current_action = Actions[bicz_anim]
	await get_tree().create_timer(anim_player.get_animation(bicz_anim).length).timeout
	
	set_colliders_enabled(tailwhip_hitbox, false)
	set_velocity(action_direction * STANDARD_SPEED)
	current_action = Actions.MOVE







#wlacza lub wylacza collidery atakow przeciwnikow
func set_colliders_enabled(area: Area2D, enabled: bool) -> void:
	for collider in area.get_children():
		collider.disabled = not enabled




func rush_conditions(path, distance_to_player, angle_to_player):
	#to sprawdza czy droga wolna dla rush; czy przeszkód nie ma
	var path_length = 0.0
	for i in range(path.size() - 1):
		path_length += path[i].distance_to(path[i + 1])
	var direct_distance = path[0].distance_to(path[-1])
	
	#to sprawdza czy slimak jest w kierunku gracza, drugi warunek ponizje
	


	return path_length == distance_to_player and angle_to_player < deg_to_rad(5)



func after_player_hit():
	set_colliders_enabled(rush_hitbox, false)
	set_colliders_enabled(tailwhip_hitbox, false)



func deal_damage(damage):
	health -= damage
	
	if health <= 0:
		#tu jakaś animacja umierania najpierw
		queue_free()
	else: #migniecie na czerwono
		#jakiś dzwięk tu puścić
		var tween = create_tween()
		tween.tween_property($Sprite2D, "modulate", Color.RED, 0.07)
		tween.tween_property($Sprite2D, "modulate", Color.WHITE, 0.07)
