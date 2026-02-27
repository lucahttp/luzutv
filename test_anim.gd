extends SceneTree
func _init():
	var scene = load("res://scenes/npcs/enemy_base.tscn").instantiate()
	var ap = scene.get_node("Model/boliviandude/frontierfriend/AnimationPlayer")
	if ap:
		print("--- ANIMATIONS FOUND ---")
		for anim in ap.get_animation_list():
			print(anim)
		print("----------------------")
	else:
		print("--- NO ANIMATION PLAYER FOUND ---")
	quit()
