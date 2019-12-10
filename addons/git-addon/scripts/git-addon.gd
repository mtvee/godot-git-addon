# ----------------------------------------------
#            ~{ GitHub Integration }~
# [Author] Jimi 
# [github] mtvee/git-addon
# [version] 0.1.0
# [date] 09.12.2019

tool
extends EditorPlugin

var doc = preload("../scenes/Git.tscn").instance()

func _enter_tree():
	#add_autoload_singleton("UserData","res://addons/github-integration/scripts/user_data.gd")
	#add_autoload_singleton("IconLoaderGithub","res://addons/github-integration/scripts/IconLoaderGithub.gd")
	get_editor_interface().get_editor_viewport().add_child(doc)
	doc.hide()


func _exit_tree():
	get_editor_interface().get_editor_viewport().remove_child(doc)
	#remove_autoload_singleton("UserData")
	#remove_autoload_singleton("IconLoaderGithub")

func has_main_screen():
	return true

func get_plugin_name():
	return "Git"

func make_visible(visible):
	doc.visible = visible
