extends Node

const SCENE_ROOT = 'res://scenes/'
const SCENES = {TITLE = 'Title', GAME = 'Game'}

var current_scene = null


func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	print(current_scene)


func _get_scene_path(scene_name: String) -> String:
	return SCENE_ROOT + scene_name + '/' + scene_name + '.tscn'


func goto_scene(scene_name: String):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:
	var path = _get_scene_path(scene_name)

	call_deferred("_deferred_goto_scene", path)


func _deferred_goto_scene(path: String):
	# It is now safe to remove the current scene
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instance()

	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)
