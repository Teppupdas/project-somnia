extends Node

@export var Loc1: String
@export var Loc2: String

func TestDomek1_entry(body: Node2D):
	print("Gracz enter")
	switch(Loc1, false)
	switch(Loc2, true)

func TestDomek1_exit(body: Node2D):
	print("Gracz exit")
	switch(Loc2, false)
	switch(Loc1, true)



func switch(group_name, active):
	for node in get_tree().get_nodes_in_group(group_name):
		if node.has_method("set_visible"):
			node.set_visible(active)
		if "disabled" in node:
			node.disabled = !active
		set_process_mode(0 if active else 4)
		
		
		
		
		
#auto import nazwy grup. Możliwy?
#auto dzieckowanie zamist dodawania koliderow do grupy
#wylaczanie monitoring w area2d zamiast disabled w koliderach
#czemu wylaczenie koliderow wymaga rowniez set process
#animacja przejscia zamiast gwaltownego przelaczenia widocznosci
#czy przy auto dzieckowaniu dalej beda dzialaly aktywatory wyjscia
