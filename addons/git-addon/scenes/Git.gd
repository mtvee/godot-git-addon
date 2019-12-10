extends MarginContainer


var git_command = 'git'
onready var commit_message = $HSplitContainer/VSplitContainer/VSplitContainer/CommitMessage
onready var git_output = $HSplitContainer/VSplitContainer/VSplitContainer2/Output

func _ready():
	if OS.get_name() == 'Windows':
		git_command = 'git.exe'
	pass # Replace with function body.


func _on_Status_pressed():
	var output = []
	OS.execute(git_command, ['status'], true, output)
	git_output.text = ''
	for line in output:
		git_output.insert_text_at_cursor(line)

func _on_Commit_pressed():
	var msg = ''
	var count = commit_message.get_line_count()
	for i in range(count):
		msg = msg + commit_message.get_line(i) + "\n"
	
	git_output.text = ''
	git_output.insert_text_at_cursor(msg)

func _on_Push_pressed():
	var output = []
	git_output.text = ''
	OS.execute(git_command, ['push'], true, output)
	for line in output:
		git_output.insert_text_at_cursor(line)

func _on_Pull_pressed():
	var output = []
	git_output.text = ''
	OS.execute(git_command, ['pull'], true, output)
	for line in output:
		git_output.insert_text_at_cursor(line)
