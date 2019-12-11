# ----------------------------------------------
#            ~{ Git Integration }~
# [Author] Jimi 
# [github] mtvee/git-addon
# [version] 0.1.0
# [date] 09.12.2019

tool
extends EditorPlugin

var doc = preload("../scenes/Git.tscn").instance()

func _enter_tree():
	get_editor_interface().get_editor_viewport().add_child(doc)
	doc.hide()

func _exit_tree():
	get_editor_interface().get_editor_viewport().remove_child(doc)

func has_main_screen():
	return true

func get_plugin_icon():
	return load("res://addons/git-addon/images/icons8-git-18.png")

func get_plugin_name():
	return "Git"

func make_visible(visible):
	doc.visible = visible
