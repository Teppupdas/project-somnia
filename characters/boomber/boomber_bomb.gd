extends CharacterBody2D

@onready var hitbox = $Hitbox
@onready var particles = $GPUParticles2D



func _ready() -> void:
	await get_tree().create_timer(2).timeout
	set_colliders_enabled(hitbox, true)
	
	particles.emitting = true
	
	#odczekanie klatki fizyki
	#wylaczenie collidera
	#wylaczenie tekstury gdy zaslonieta czasteczkami
	
	
	
	await get_tree().create_timer(0.5).timeout
	queue_free()







#wlacza lub wylacza collidery atakow przeciwnikow
func set_colliders_enabled(area: Area2D, enabled: bool) -> void:
	for collider in area.get_children():
		collider.disabled = not enabled



func after_player_hit():
	set_colliders_enabled(hitbox, false)
