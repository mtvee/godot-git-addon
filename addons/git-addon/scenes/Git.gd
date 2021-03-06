tool
extends MarginContainer

# note:
# can make this output easily parsable with --porcelain=2 option
# then can make the output a list and add some operations to each
# item

var git_command = 'git'
onready var commit_message = $HSplitContainer/VSplitContainer/VSplitContainer/CommitMessage
onready var git_output = $HSplitContainer/VSplitContainer/Tabs/Output
onready var git_files = $HSplitContainer/VSplitContainer/Tabs/FilesList

onready var status_changed = load("res://addons/git-addon/images/check-18.png")
onready var status_untracked = load("res://addons/git-addon/images/plus-18.png")
onready var status_deleted = load("res://addons/git-addon/images/zap-18.png")

const tmp_filename = 'gitcommit.txt'
var popup


# change the executable name for windows
func _ready():
	if OS.get_name() == 'Windows':
		git_command = 'git.exe'
	$HSplitContainer/GridContainer/Add.disabled = true
	popup = AcceptDialog.new()
	self.add_child(popup)

# runs the git_command with args
# TODO: this thing doesn't seem to capture stderr output so probably have to use some
# redirected voodoo. Also doesn't return the return value from the process, ugh.
# Need to figure out how to do that in windows	
# note: fixed push by adding --porcelain so output goes to stdout
func run_commmand( args ):
	git_output.text = ''
	var output = []
	OS.execute(git_command, args, true, output)
	# if we got nothing indicate an error
	if len(output) == 1 and len(output[0]) == 0:
		popup.dialog_text = "Something went wrong\n\ncheck the godot console output"
		popup.popup_centered()
	for line in output:
		git_output.insert_text_at_cursor(line)

# able/disable buttons and whatnot
func update_ui():
	var items = git_files.get_selected_items()
	if len(items) == 0:
		$HSplitContainer/GridContainer/Add.disabled = true
		return
	var have_additions = false
	for item in items:
		if git_files.get_item_metadata(item) == '?':	
			have_additions = true
			
	if have_additions:
		$HSplitContainer/GridContainer/Add.disabled = false
				
			
func _on_Status_pressed():
	run_commmand(['status'])
	var output = []
	git_files.clear()
	OS.execute(git_command, ['status','--porcelain'], true, output)
	output = output[0].split("\n")
	for line in output:
		if len(line) == 0:
			continue
		var code = line.substr(0, 2)
		var fname = line.substr(3, len(line)-3)
		# changed
		if code == ' M':
			git_files.add_item(fname, status_changed)
			var cnt = git_files.get_item_count()
			git_files.set_item_custom_fg_color(cnt-1, Color.green)
			git_files.set_item_metadata(cnt-1, 'M')
		# untracked
		if code == '??':
			git_files.add_item(fname, status_untracked)
			var cnt = git_files.get_item_count()
			git_files.set_item_custom_fg_color(cnt-1, Color.yellow)
			git_files.set_item_metadata(cnt-1, '?')
		# added
		if code == 'A ':
			git_files.add_item(fname, status_changed)
			var cnt = git_files.get_item_count()
			git_files.set_item_custom_fg_color(cnt-1, Color.cyan)
			git_files.set_item_metadata(cnt-1, 'A')
		if code == 'D ':
			git_files.add_item(fname, status_deleted)
			var cnt = git_files.get_item_count()
			git_files.set_item_custom_fg_color(cnt-1, Color.red)
			git_files.set_item_metadata(cnt-1, 'D')
				
			$HSplitContainer/GridContainer/Add.disabled = true
	update_ui()

func _on_Commit_pressed():
	var msg = ''
	var count = commit_message.get_line_count()
	if count == 1 and commit_message.get_line(0) == '':
		var diag = AcceptDialog.new()
		diag.get_label().text = "No commit message"
		self.add_child(diag)
		diag.popup_centered()
		return
	for i in range(count):
		msg = msg + commit_message.get_line(i) + "\n"
	var tmp_file = File.new()
	tmp_file.open(tmp_filename, File.WRITE)
	tmp_file.store_line(msg)
	tmp_file.close()
	run_commmand(['commit', '-a', '-F', tmp_filename])
	var dir = Directory.new()
	dir.remove(tmp_filename)
	_on_Status_pressed()
	
func _on_Push_pressed():
	run_commmand(['push', '--porcelain'])

func _on_Pull_pressed():
	run_commmand(['pull'])

func _on_Add_pressed():
	var items = git_files.get_selected_items()
	for ndx in items:
		run_commmand(['add', git_files.get_item_text(ndx)])		
	_on_Status_pressed()

func _on_SelAll_pressed():
	git_files.unselect_all()
	for idx in range(git_files.get_item_count()):
		git_files.select(idx, false)
	update_ui()

func _on_SelUntracked_pressed():
	git_files.unselect_all()
	for idx in range(git_files.get_item_count()):
		if git_files.get_item_metadata(idx) == '?':
			git_files.select(idx, false)
	update_ui()

func _on_SelNone_pressed():
	git_files.unselect_all()
	update_ui()

func _on_FilesList_multi_selected(index, selected):
	update_ui()