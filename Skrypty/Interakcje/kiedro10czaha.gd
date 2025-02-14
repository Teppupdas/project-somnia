extends Node2D

var saveNode: NodePath = "../../save"
var UI: NodePath = "../../CanvasLayer"

var baseActions: Array # to zapisywac
var toActionPrompt #zapamioetuje co obecnie ma sie pojawic w actionpromptt




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
			
			startConv(actionName)
		"CZAHA2": #ty gadasz?
			toActionPrompt = ["CZAHA2-1", "CZAHA2-2"]
			startConv(actionName)
		"CZAHA2-1", "CZAHA2-2":
			baseActions.erase("CZAHA2")
			baseActions.push_front("CZAHA4")
			toActionPrompt = baseActions
			get_node(UI).updateActionPrompt(toActionPrompt)
		"CZAHA3": #jak stąd wyjść
			baseActions.erase(actionName)
			toActionPrompt = baseActions
			startConv(actionName)
			get_node(saveNode).candleActimelizing() # to robi ze swieczek mozna uzyc
		"CZAHA4", "CZAHA5": #a ty co tu robisz
			baseActions.erase(actionName)
			toActionPrompt = baseActions
			startConv(actionName)
		"CZAHA6": #to jescze nie jest dodawan nigdzie
			startConv(actionName)





func startConv(baseKey: String):
	#if tr(key) == key:  # Sprawdza, czy klucz istnieje
	get_node(UI).startConversation(baseKey + ".")
	
	#jesli tablica pusta to wylaczyc action prompt a jesli cos jest to zaktualizowac
	if toActionPrompt:
		get_node(UI).updateActionPrompt(toActionPrompt)
	else:
		get_node(UI).hideActionPrompt()




func _on_area_2d_body_entered(body: Node2D) -> void:
	if toActionPrompt:
		get_node(UI).showActionPrompt(toActionPrompt, self)


func _on_area_2d_body_exited(body: Node2D) -> void:
	get_node(UI).hideActionPrompt()
