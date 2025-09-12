extends CharacterBody2D



@onready var player = $"../Gracz"

@onready var sprite_2d = $Sprite2D
@onready var nav_agent = $NavigationAgent2D
@onready var sub_viewport = $SubViewport
@onready var model_3d = $SubViewport/boomber
@onready var anim_player = model_3d.get_node("AnimationPlayer")
@onready var gun = model_3d.get_node("Armature/Skeleton3D/Gun")

@onready var hitbox = $Hitbox
@onready var bullet_scene = preload("res://characters/boomber/boomber_bullet.tscn")
@onready var bomb_scene = preload("res://characters/boomber/boomber_bomb.tscn")

var timer_accumulator = randf()

var interval = 1.0



var health = 13

enum Actions { STAY, MOVE, SHOOT, DEPLOY_BOMB }
var current_action: Actions = Actions.STAY
var action_direction = Vector2.ZERO
var gun_direction = Vector2.ZERO

const STANDARD_SPEED = 900
const TURN_SPEED = 7.0




func _ready() -> void:
	bomb()



func _process(delta: float) -> void:
	gun.rotation = Vector3(0, -atan2(gun_direction.y, gun_direction.x), 0)
	anim_player.play(Actions.find_key(current_action))
	sprite_2d.texture = sub_viewport.get_texture()







func _physics_process(delta):
	var distance_to_player = global_position.distance_to(player.global_position)
	
	
	
	
	if current_action == Actions.STAY:
		timer_accumulator += delta
		gun_direction = (player.global_position - global_position).normalized()
		
	if timer_accumulator >= interval:
		timer_accumulator -= interval
		 
		if distance_to_player < 1300:
			pass
		elif distance_to_player < 1500 and randf() < 0.2:
			pass
		else:
			pass


	move_and_slide() #poruszanie się to powoduje







func move():
	current_action = Actions.MOVE








func shoot():
	current_action = Actions.SHOOT
	gun_direction = (player.global_position - global_position).normalized()
	var bullet_direction = ((player.global_position + Vector2(0,-1)) - global_position).normalized()
	
	var bullet_instance = bullet_scene.instantiate()
	bullet_instance.direction = bullet_direction
	add_child(bullet_instance)
	
	await get_tree().create_timer(anim_player.get_animation("SHOOT").length).timeout
	current_action = Actions.STAY





func bomb():
	current_action = Actions.DEPLOY_BOMB

	await get_tree().create_timer(anim_player.get_animation("DEPLOY_BOMB").length).timeout


	var bomb = bomb_scene.instantiate()
	get_parent().add_child(bomb)

	current_action = Actions.STAY

















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
