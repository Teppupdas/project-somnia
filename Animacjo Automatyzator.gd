@tool
extends EditorScript

var FPS = 120
var path = "res://Charakterki/Player/Dash/" #kończyć z ukośnikiem: /
var resolution: Vector2 = Vector2(420, 420)
#gracz - 420
#duchol - 400
var loop_animation: bool = false

var sprite = get_editor_interface().get_edited_scene_root().get_node("World YSort/Gracz/Sprite2Dgracz")
var anim_player = get_editor_interface().get_edited_scene_root().get_node("World YSort/Gracz/AnimationPlayer")
var anim_tree = get_editor_interface().get_edited_scene_root().get_node("World YSort/Gracz/AnimationTree")


var generated_animations: Array[String] = []  # <- dodaj to globalnie nad funkcją _run()
var blend_radius = 1.0
var directions = [
	"S", "SbE", "SSE", "SEbS", "SE", "SEbE", "ESE", "EbS",
	"E", "EbN", "ENE", "NEbE", "NE", "NEbN", "NNE", "NbE",
	"N", "NbW", "NNW", "NWbN", "NW", "NWbW", "WNW", "WbN",
	"W", "WbS", "WSW", "SWbW", "SW", "SWbS", "SSW", "SbW"
]
func _run():
	_create_animation()
	_create_blendspace()
	print("ZAKOŃCZONO.")

func _create_animation():
	var dir = DirAccess.open(path)
	if not dir:
		push_error("Nie można otworzyć folderu: %s" % path)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".png"):
			var full_path = path + file_name
			var anim_name = file_name.get_basename().get_file()
			var texture = load(full_path)
			if not texture:
				push_error("Nie można załadować tekstury: %s" % full_path)
				file_name = dir.get_next()
				continue

			var texture_size = texture.get_size()
			var hframes = texture_size.x / resolution.x
			var vframes = texture_size.y / resolution.y
			var frame_count = hframes * vframes

			var anim_lib_name = path.get_file()
			if not anim_player.has_animation_library(anim_lib_name):
				anim_player.add_animation_library(anim_lib_name, AnimationLibrary.new())

			var anim_lib = anim_player.get_animation_library(anim_lib_name)
			if not anim_lib:
				push_error("Nie udało się pobrać AnimationLibrary dla %s." % anim_lib_name)
				file_name = dir.get_next()
				continue

			# Jeśli animacja istnieje, usuń ją przed dodaniem nowej
			if anim_lib.has_animation(anim_name):
				anim_lib.remove_animation(anim_name)
				print("Usunięto animację: "+ anim_name)

			var anim = Animation.new()
			anim.length = frame_count / FPS
			anim.loop_mode = Animation.LOOP_LINEAR if loop_animation else Animation.LOOP_NONE

			var sprite_path = NodePath(sprite.name)

			var t1 = anim.add_track(Animation.TYPE_VALUE)
			anim.track_set_path(t1, str(sprite_path) + ":texture")
			anim.track_insert_key(t1, 0.0, texture)

			var t2 = anim.add_track(Animation.TYPE_VALUE)
			anim.track_set_path(t2, str(sprite_path) + ":hframes")
			anim.track_insert_key(t2, 0.0, hframes)

			var t3 = anim.add_track(Animation.TYPE_VALUE)
			anim.track_set_path(t3, str(sprite_path) + ":vframes")
			anim.track_insert_key(t3, 0.0, vframes)

			var t4 = anim.add_track(Animation.TYPE_VALUE)
			anim.track_set_path(t4, str(sprite_path) + ":frame")
			for i in range(frame_count):
				var time = float(i) / FPS
				anim.track_insert_key(t4, time, i)

			anim_lib.add_animation(anim_name, anim)
			generated_animations.append(anim_name)  # <- dodajemy animację do listy
			print("Dodano animację: "+ anim_name)

		file_name = dir.get_next()
	dir.list_dir_end()



func _create_blendspace() -> void:
	var state_machine = anim_tree.tree_root
	if typeof(state_machine) != TYPE_OBJECT or not state_machine is AnimationNodeStateMachine:
		push_error("root AnimationTree nie jest AnimationNodeStateMachine!")
		return

	var blendspace_name = path.rstrip("/").get_file() #tu usuniecie koncowego srednika w celu pobrania nazwy folderu

# Jeśli istnieje, usuń go i stwórz nowy
	if state_machine.has_node(blendspace_name):
		print("Blendspace %s już istnieje - usuwam i tworzę nowy." % blendspace_name)
		state_machine.remove_node(blendspace_name)

	var blendspace = AnimationNodeBlendSpace2D.new()
	blendspace.blend_mode = AnimationNodeBlendSpace2D.BLEND_MODE_DISCRETE
	state_machine.add_node(blendspace_name, blendspace)
	print("Dodano nowy blendspace o nazwie %s" % blendspace_name)

	
	
	
	
	
	# Dodanie animacji jako punktów blendu
	var lib_name = path.get_file()
	var anim_lib = anim_player.get_animation_library(lib_name)
	if not anim_lib:
		push_error("Nie znaleziono AnimationLibrary: %s" % lib_name)
		return

	for i in range(generated_animations.size()):
		var anim_name = generated_animations[i]
		
		var suffix = anim_name.split("_")[-1] #dziala tylkoi jesli jest jedno podkreslenie w nazwie
		var index = directions.find(suffix)
		if index == -1:
			push_warning("Nie znaleziono kierunku dla: " + suffix)
			continue
		
		var angle = deg_to_rad(index * 11.25) # 360 / 32 = 11.25
		var pos = Vector2(sin(angle), -cos(angle)) * blend_radius
		
		
		var anim_node = AnimationNodeAnimation.new()
		anim_node.animation = anim_name
		
		blendspace.add_blend_point(anim_node, pos)
		print("Dodano animację '%s' do blendspace w pozycji %s" % [anim_name, pos])
