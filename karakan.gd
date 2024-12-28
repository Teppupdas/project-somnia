extends CharacterBody2D

var maxHealth: int = 10
var currentHealth

func _ready() -> void:
	currentHealth = maxHealth


func _process(delta: float) -> void:
	pass

func dealDamage(damage: int):
		currentHealth -= damage
		print("Karakan życie: " + str(currentHealth))
		if currentHealth <= 0:
			print("martwy karakan")
			queue_free()
