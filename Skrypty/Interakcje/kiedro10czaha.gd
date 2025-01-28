extends Node2D

@onready var saveNode = $"../../save"
var UI: NodePath = "../../CanvasLayer"

var thisInteractionState = 0 # to bedzie trzeba zapisywac
var playerInArea = false
var toActionPrompt: Array = ["CZAHA1", "CZAHA2"]

func _ready() -> void:
	get_node(UI).connect("actionConfirmed", onActionConfirmed) #nazwa sygnalu, nazwa funckji



func _process(delta: float) -> void:
	if playerInArea and Input.is_action_just_pressed("potwierdz"):
		match thisInteractionState:
			0:
				#toActionPrompt = "CZAHA77" #niedodane dodac ze rozmawiaj albo nie dawac wiecej gadac z czaszka XDD
				get_node(UI).startConversation("CZAHA2")
			1:
				pass
		
		
		#
		
		
		
		
		#po spytaniu o droge XD
		if saveNode.storyState == 0:
			saveNode.storyState = 1


func onActionConfirmed(actionName: String) -> void:
	print("Wybrano kurwa opcję: ", actionName)
	$"../../CanvasLayer/debugLabel".text = actionName








func _on_area_2d_body_entered(body: Node2D) -> void:
	playerInArea = true
	get_node(UI).showActionPrompt(toActionPrompt)
	
func aktualizujActionPrompt():
	pass


func _on_area_2d_body_exited(body: Node2D) -> void:
	playerInArea = false
	get_node(UI).hideActionPrompt()




#rozwazyc przerobienie z sygnalow na bezposrednie do danego skryptu ze wzgledu na wydajnosc bo za duzo na raz odbiera sygnal
#swieczke przerobic pierwej lub nie pierwej
 # w przeniesienie story do story za pomoca sygnalu zmienna can save candle czy chuj wie co a nie story state chyba XD chuj dupa cycki
	#w tym skrypcie zarzadzanie ta tablica i wykonywanie tego co zostalo wybrane
	#zapisywanie tego i wczytywanie bez potrzebyu przypisania tu sava
