extends CharacterBody2D
# movement poprawic, cale obracanie sie itp. pathtracking chyba
# bite przerobic. windup dodac chyba, skok jakis lepszy i recovery


@onready var player = $"../Gracz"

@onready var sprite_2d = $Sprite2D
@onready var nav_agent = $NavigationAgent2D
@onready var sub_viewport = $SubViewport
@onready var model_3d = $SubViewport/speeder
@onready var anim_player = model_3d.get_node("AnimationPlayer")

@onready var hitbox = $Hitbox
@onready var speeder_web_scene = preload("res://characters/speeder/speeder_web.tscn")


var timer_accumulator = randf()

var interval = 1.0



var health = 7

enum Actions { STAY, MOVE, BITE_WINDUP, BITE_LOT, BITE_RECOVERY, WEBSHOT }
var current_action: Actions = Actions.STAY
var action_direction = Vector2.ZERO

const STANDARD_SPEED = 900
const TURN_SPEED = 7.0

var bite_timer: SceneTreeTimer = null
const BITE_SPEED = 2000







func _process(delta: float) -> void:
	model_3d.rotation = Vector3(0, -atan2(action_direction.y, action_direction.x), 0)
	anim_player.play(Actions.find_key(current_action))
	sprite_2d.texture = sub_viewport.get_texture()







func _physics_process(delta):
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if current_action == Actions.STAY:
		timer_accumulator += delta
		
	if timer_accumulator >= interval:
		timer_accumulator -= interval
		 
		if distance_to_player < 600:
			bite(delta, distance_to_player)
		elif distance_to_player < 1500 and randf() < 0.2:
			webshot()
		else:
			move()


	move_and_slide() #poruszanie się to powoduje






func move():
	current_action = Actions.MOVE
	var radius = 700
	var nav_map_rid = nav_agent.get_navigation_map()

	for i in range(13):
		var random_offset = Vector2(randf_range(-radius, radius), randf_range(-radius, radius))
		if random_offset.length() > radius:
			continue
		
		var candidate = global_position + random_offset
		var nav_point = NavigationServer2D.map_get_closest_point(nav_map_rid, candidate)

		
		if nav_point.distance_to(candidate) < 10.0 and nav_point.distance_to(global_position) > 5.0:
			action_direction = (nav_point - global_position).normalized()
			var travel_time = global_position.distance_to(nav_point) / STANDARD_SPEED
			
			set_velocity(action_direction * STANDARD_SPEED)
			await get_tree().create_timer(travel_time).timeout
			
			set_velocity(Vector2.ZERO)
			current_action = Actions.STAY
			break






func bite(delta, distance_to_player):
	current_action = Actions.BITE_WINDUP
	action_direction = (player.global_position - global_position).normalized()
	hitbox.rotation = action_direction.angle()
	var bite_travel_time = distance_to_player / BITE_SPEED
	
	
	
	
	await get_tree().create_timer(anim_player.get_animation("BITE_WINDUP").length).timeout
	
	current_action = Actions.BITE_LOT
	
	set_colliders_enabled(hitbox, true)
	bite_timer = get_tree().create_timer(bite_travel_time)
	set_velocity(action_direction * BITE_SPEED)
	await bite_timer.timeout
	
	current_action = Actions.BITE_RECOVERY
	
	bite_timer = null
	set_velocity(Vector2.ZERO)
	set_colliders_enabled(hitbox, false)
	
	await get_tree().create_timer(anim_player.get_animation("BITE_RECOVERY").length).timeout
	
	current_action = Actions.STAY







func webshot():
	current_action = Actions.WEBSHOT
	action_direction = (global_position - player.global_position).normalized() #tyłem
	var web_direction = ((player.global_position + Vector2(0,-130)) - global_position).normalized()
	

	await get_tree().create_timer(anim_player.get_animation("WEBSHOT").length).timeout
	
	var speeder_web_instance = speeder_web_scene.instantiate()
	speeder_web_instance.direction = web_direction
	add_child(speeder_web_instance)
	
	current_action = Actions.STAY
	









#wlacza lub wylacza collidery atakow przeciwnikow
func set_colliders_enabled(area: Area2D, enabled: bool) -> void:
	for collider in area.get_children():
		collider.disabled = not enabled







func after_player_hit():
	set_colliders_enabled(hitbox, false)
	
	# zatrzymuje ruch bite 
	if bite_timer:
		bite_timer.emit_signal("timeout")



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
