extends Node2D

var saveNode: NodePath = "../../save"
var UI: NodePath = "../../CanvasLayer"

var baseActions: Array = ["GAD1", "GAD2"] # to zapisywac
var toActionPrompt #zapamioetuje co obecnie ma sie pojawic w actionpromptt

var dialogueBubbleOffset = Vector2(0, 200)

var playerInArea = false
var isTalking = false #to jest sprawdzane by wstrzymac pokazywanie akcji



func _ready() -> void:
	toActionPrompt = baseActions
func _process(delta: float) -> void:
	pass


func handleAction(actionName: String) -> void:
	match actionName:
		"GAD1":
			initiateDialogue(actionName)
		"GAD2":
			initiateDialogue(actionName)




func initiateDialogue(baseKey: String):
	#if tr(key) == key:  # Sprawdza, czy klucz istnieje
	get_node(UI).dialogueBubble(baseKey + ".")
	
	#jesli tablica pusta to wylaczyc action prompt a jesli cos jest to zaktualizowac
	if toActionPrompt:
		get_node(UI).updateActionPrompt(toActionPrompt)
	else:
		get_node(UI).hideActionPrompt()




func _on_area_2d_body_entered(body: Node2D) -> void:
	playerInArea = true
	if toActionPrompt:
		get_node(UI).showActionPrompt(toActionPrompt, self)


func _on_area_2d_body_exited(body: Node2D) -> void:
	playerInArea = false
	get_node(UI).hideActionPrompt()
