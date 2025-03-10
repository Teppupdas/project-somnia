extends Node2D

var saveNode: NodePath = "../../save"
var UI: NodePath = "../../CanvasLayer"

var baseActions: Array # to zapisywac
var toActionPrompt #zapamioetuje co obecnie ma sie pojawic w actionpromptt

var dialogueBubbleOffset = Vector2(100, -150)

var playerInArea = false
var isTalking = false #to jest sprawdzane by wstrzymac pokazywanie akcji



func _ready() -> void:
	toActionPrompt = baseActions
func _process(delta: float) -> void:
	pass


func handleAction(actionName: String) -> void:
	match actionName:
		"CZAHA1":
			baseActions.erase(actionName)
			baseActions.append("CZAHA2")
			baseActions.append("CZAHA3")
			baseActions.append("CZAHA5")
			toActionPrompt = baseActions
			
			initiateDialogue(actionName)
		"CZAHA2": #ty gadasz?
			toActionPrompt = ["CZAHA2-1", "CZAHA2-2"]
			initiateDialogue(actionName)
		"CZAHA2-1", "CZAHA2-2":
			baseActions.erase("CZAHA2")
			baseActions.push_front("CZAHA4")
			toActionPrompt = baseActions
			get_node(UI).updateActionPrompt(toActionPrompt)
		"CZAHA3": #jak stąd wyjść
			baseActions.erase(actionName)
			toActionPrompt = baseActions
			initiateDialogue(actionName)
		"CZAHA4", "CZAHA5":
			baseActions.erase(actionName)
			toActionPrompt = baseActions
			initiateDialogue(actionName)
		"CZAHA6": #to jescze nie jest dodawan nigdzie
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
	
