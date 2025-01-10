extends Node

@onready var player = $"../World YSort/Gracz"
@onready var UI = $"../CanvasLayer"


var currentCandle: Node2D = null # Przechowuje obecnie zapaloną świeczkę
var maxHealth



func _ready():
	call_deferred("loadGame") #opóżnione wywołąnie bo sie bugowało że było null instance
	pass







func saveGame():
	var config = ConfigFile.new()

	config.set_value("candle", "current_candle", currentCandle.name)
	config.set_value("player", "maxHealth", player.maxHealth)


	var error = config.save("user://save_game.txt")  # Zapis
	if error == OK:
		print("zapisano")
	else:
		print("zapis wypierdolony")


func loadGame():
	var config = ConfigFile.new()
	var error = config.load("user://save_game.txt")  # Odczyt

	if error == OK:
		print("wczytano")
		# Odczytujemy nazwę świeczki
		
		setCandle(get_node("../World YSort/" + config.get_value("candle", "current_candle", ""))) #zapalenie swieczki i jej wybor
		player.position = currentCandle.position #pozycja gracza na sieczke
		
		player.maxHealth = config.get_value("player", "maxHealth", player.maxHealth) # ustawianie maksymalnego zycia
		player.currentHealth = config.get_value("player", "maxHealth", player.maxHealth) # ustawianianie obencego zycia
		UI.setMaxHeart(player.maxHealth)
		#UI.updateHearts(player.maxHealth)
		
	else:
		print("wczytywanie wypierdolone")












# świeczkaaaa
func setCandle(candle: Node2D) -> void:
	if currentCandle: # sprawdza czy jest jakas przypisana zapalona
		currentCandle.turnOffCandle() #gasi tą przypisana poprzednia
		
	currentCandle = candle # przypisuje nowa
	currentCandle.turnOnCandle()  # zapala nowa
	
