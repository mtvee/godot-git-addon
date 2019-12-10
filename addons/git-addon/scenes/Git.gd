tool
extends MarginContainer


var git_command = 'git'
onready var commit_message = $HSplitContainer/VSplitContainer/VSplitContainer/CommitMessage
onready var git_output = $HSplitContainer/VSplitContainer/VSplitContainer2/Output

const tmp_filename = 'gitcommit.txt'

func _ready():
	if OS.get_name() == 'Windows':
		git_command = 'git.exe'
	pass # Replace with function body.

func _on_Status_pressed():
	run_commmand(['status'])
	
func _on_Commit_pressed():
	var msg = ''
	var count = commit_message.get_line_count()
	for i in range(count):
		msg = msg + commit_message.get_line(i) + "\n"
	var tmp_file = File.new()
	tmp_file.open(tmp_filename, File.WRITE)
	tmp_file.store_line(msg)
	tmp_file.close()
	run_commmand(['commit', '-a', '-F', tmp_filename])
	var dir = Directory.new()
	dir.remove(tmp_filename)
	
func _on_Push_pressed():
	run_commmand(['push'])

func _on_Pull_pressed():
	run_commmand(['pull'])

func run_commmand( args ):
	git_output.text = ''
	var output = []
	OS.execute(git_command, args, true, output)
	for line in output:
		git_output.insert_text_at_cursor(line)
	
	
	