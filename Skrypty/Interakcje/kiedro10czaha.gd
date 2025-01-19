extends Node2D

@onready var saveNode = $"../../save"
@onready var label = $"../../CanvasLayer/Interakcji/Label"


var thisInteractionState = 0
var playerInArea = false

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if playerInArea and Input.is_action_just_pressed("potwierdz"):
		if saveNode.storyState == 0:
			saveNode.storyState = 1




func _on_area_2d_body_entered(body: Node2D) -> void:
	playerInArea = true
	label.text = "Kopnij"
	label.visible = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	playerInArea = false
	label.visible = false



# lokalizacje
# robic tak zeby dalo sie ruszac podczas rozmowy taki interfejs wymyslic
# czaszka cos gada i wtedy wybor dialogow
#troche gadania i gdy czaszka mowi ze mozna swieczke zapaoilc i drzwi otworzyc to mozna XD
