extends Node

@onready var player = $"../World YSort/Gracz"
@onready var UI = $"../CanvasLayer"


var currentCandle: Node2D = null # Przechowuje obecnie zapaloną świeczkę

var storyState
	# 0 = start gry
	# 1 = pogadane z czaszka, mozliwosc zapalenia swieczki
	# 2 = swieczka zapalona, mozliwosc otwarcia drzwi














func _ready():
	call_deferred("loadGame") #opóżnione wywołąnie bo sie bugowało że było null instance
	pass







func saveGame():
	var dataFile = ConfigFile.new()

	dataFile.set_value("player", "candle", currentCandle.name)
	dataFile.set_value("player", "maxHealth", player.maxHealth)

	dataFile.set_value("story", "storyState", storyState)


	var error = dataFile.save("user://save_game.txt")  # Zapis
	if error == OK:
		print("zapisano")
	else:
		print("zapis wypierdolony")


func loadGame():
	var dataFile = ConfigFile.new()
	var error = dataFile.load("user://save_game.txt")  # Odczyt

	if error == OK:
		print("wczytano")
		# Odczytujemy nazwę świeczki
		
		player.maxHealth = dataFile.get_value("player", "maxHealth", player.maxHealth) # ustawianie maksymalnego zycia
		player.currentHealth = dataFile.get_value("player", "maxHealth", player.maxHealth) # ustawianianie obencego zycia
		UI.setMaxHeart(player.maxHealth)
		UI.updateHearts(player.maxHealth)
		
		setCandle(get_node("../World YSort/" + dataFile.get_value("player", "candle", ""))) #zapalenie swieczki i jej wybor
		player.position = currentCandle.position #pozycja gracza na swieczke
		
		storyState = dataFile.get_value("story", "storyState", storyState)
		
	else:
		print("wczytywanie wypierdolone")
		# wartości na start gdy sejwa nie ma
		player.maxHealth = 3 # ustawianie maksymalnego zycia
		player.currentHealth = 3 # ustawianianie obencego zycia
		UI.setMaxHeart(player.maxHealth)
		UI.updateHearts(player.maxHealth)
		
		player.position = Vector2.ZERO
		
		storyState = 0
	












# świeczkaaaa
func setCandle(candle: Node2D) -> void:
	player.currentHealth = player.maxHealth #leczenie gracza gdy swieczki dotknie
	UI.updateHearts(player.currentHealth)
	
	if storyState == 1:
		storyState = 2
	
	if currentCandle: # sprawdza czy jest jakas przypisana zapalona
		currentCandle.turnOffCandle() #gasi tą przypisana poprzednia
		
	currentCandle = candle # przypisuje nowa
	currentCandle.turnOnCandle()  # zapala nowa
	
