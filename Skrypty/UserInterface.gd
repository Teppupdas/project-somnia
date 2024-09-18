extends CanvasLayer

@onready var pasekSerc = $Serduszka
@onready var player = $"../YSort/Gracz"
@onready var heartPrefab = preload("res://Interfejsik/serce.tscn")

@onready var pauzyMenu = $TextureRect
@onready var Label1 = $TextureRect/VBoxContainer/Label1
@onready var Label2 = $TextureRect/VBoxContainer/Label2
var pauzaAktywna
var opcjaWybrana





func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN) #ukrycie myszki
	
	setMaxHeart(player.maxHealth)
	updateHearts(player.currentHealth)
	player.healthChanged.connect(updateHearts)



	pauzaAktywna = false
	pauzyMenu.hide()
	pasekSerc.show()
	get_tree().paused = false
	opcjaWybrana = 1




func _process(delta: float) -> void:
	if pauzaAktywna:
		if Input.is_action_just_pressed("pauza"):
			pauzaAktywna = false
			pauzyMenu.hide()
			pasekSerc.show()
			get_tree().paused = false
			opcjaWybrana = 1


		if Input.is_action_just_pressed("potwierdz"):
			match opcjaWybrana:
				1:
					pauzaAktywna = false
					pauzyMenu.hide()
					pasekSerc.show()
					get_tree().paused = false
				2:
					get_tree().quit()


		if Input.is_action_just_pressed("gora"):
			match opcjaWybrana:
				1:
					opcjaWybrana = 2
				2:
					opcjaWybrana = 1
		if Input.is_action_just_pressed("dol"):
			match opcjaWybrana:
				1:
					opcjaWybrana = 2
				2:
					opcjaWybrana = 1


		match opcjaWybrana:
			1:
				Label1.set("theme_override_colors/font_color", Color8(220, 20, 60))
				Label2.set("theme_override_colors/font_color", Color8(255, 255, 255))
			2:
				Label1.set("theme_override_colors/font_color", Color8(255,255,255))
				Label2.set("theme_override_colors/font_color", Color8(220, 20, 60))

	elif Input.is_action_just_pressed("pauza"):
		pauzaAktywna = true
		get_tree().paused = true
		pasekSerc.hide()
		pauzyMenu.show()




func setMaxHeart(max: int):
	# Upewniamy się, że HBoxContainer istnieje
	if pasekSerc:
		for i in range(max):
			var heart = heartPrefab.instantiate()
			pasekSerc.add_child(heart)

func updateHearts(currentHealth):
	var hearts = pasekSerc.get_children()

	for i in range(currentHealth):
		hearts[i].update(true)

	for i in range(currentHealth, hearts.size()):
		hearts[i].update(false)
