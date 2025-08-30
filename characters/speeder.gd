extends CharacterBody2D
@onready var player = $"../Gracz"

@onready var sprite_2d = $Sprite2D
@onready var nav_agent = $NavigationAgent2D
@onready var sub_viewport = $SubViewport
@onready var model_3d = $SubViewport/speeder
@onready var anim_player = model_3d.get_node("AnimationPlayer")

@onready var hitbox = $Hitbox


var health = 7

enum Actions { STAY, MOVE }
var current_action: Actions = Actions.MOVE
var action_direction = Vector2.ZERO

const STANDARD_SPEED = 900
const TURN_SPEED = 7.0








func _process(delta: float) -> void:
	model_3d.rotation = Vector3(0, -atan2(action_direction.y, action_direction.x), 0)
	anim_player.play(Actions.find_key(current_action))
	sprite_2d.texture = sub_viewport.get_texture()







func _physics_process(delta):
	var random = randi_range(0,1000)
	var distance_to_player = global_position.distance_to(player.global_position)
	
	
	
	
	
	#if ditance_to_player <
	
	
	
	nav_agent.target_position = player.global_position
	
	
	#płynny obrót w kierunku path
	var target_angle = (nav_agent.get_next_path_position() - global_position).angle()
	var current_angle = action_direction.angle()
	var new_angle = lerp_angle(current_angle, target_angle, TURN_SPEED * delta)
	action_direction = Vector2.RIGHT.rotated(new_angle)
	
	
	hitbox.rotation = action_direction.angle()
	
	set_velocity(action_direction * STANDARD_SPEED)
	move_and_slide() #poruszanie się to powoduje







#wlacza lub wylacza collidery atakow przeciwnikow
func set_colliders_enabled(area: Area2D, enabled: bool) -> void:
	for collider in area.get_children():
		collider.disabled = not enabled







func after_player_hit():
	set_colliders_enabled(hitbox, false)


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
