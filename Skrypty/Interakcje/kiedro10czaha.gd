extends Node2D

@onready var saveNode = $"../../save"
var UI: NodePath = "../../CanvasLayer"

var thisInteractionState = 0 # to bedzie trzeba zapisywac
var playerInArea = false
var toActionPrompt: String = "CZAHA1"

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if playerInArea and Input.is_action_just_pressed("potwierdz"):
		match thisInteractionState:
			0:
				toActionPrompt = "CZAHA77" #niedodane dodac ze rozmawiaj albo nie dawac wiecej gadac z czaszka XDD
				get_node(UI).startConversation("CZAHA2")
			1:
				pass
		
		
		#
		
		
		
		
		#po spytaniu o droge XD
		if saveNode.storyState == 0:
			saveNode.storyState = 1




func _on_area_2d_body_entered(body: Node2D) -> void:
	playerInArea = true
	get_node(UI).showActionPrompt(toActionPrompt)
	
func aktualizujActionPrompt():
	pass


func _on_area_2d_body_exited(body: Node2D) -> void:
	playerInArea = false
	get_node(UI).hideActionPrompt()



	#przekazywac kilka mozliwcyh wyborow do action prompt tak zeby to ladnie wygladalao
	#usuwac konkrenty po wybraniu go jesli ma byc usuniety
	#aktualizowac to gdzies wyzej anie tylkko po wejsciu w area. trzeba by do tego oddzielna funkjce napisac chyba
	#dodac dymek mowienia albo jakis interfejsik caly
	#zastanowic sie czy aktywny system dialogow to dobry pomysl
	
	
	
