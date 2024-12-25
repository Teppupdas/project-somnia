extends CharacterBody2D

var maxHealth
var currentHealth

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.name == "playerHitBox": # and !dashing:
		
		currentHealth -=1
		if currentHealth == 0:
			currentHealth = maxHealth
