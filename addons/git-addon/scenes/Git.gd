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
	popup = PopupMenu.new()


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
	run_commmand(['push'])

func _on_Pull_pressed():
	run_commmand(['pull'])

func _on_Add_pressed():
	var items = git_files.get_selected_items()
	for ndx in items:
		run_commmand(['add', git_files.get_item_text(ndx)])		
	_on_Status_pressed()

# runs the git_command with args
func run_commmand( args ):
	git_output.text = ''
	var output = []
	OS.execute(git_command, args, true, output)
	for line in output:
		git_output.insert_text_at_cursor(line)
	

func _on_SelAll_pressed():
	git_files.unselect_all()
	for idx in range(git_files.get_item_count()):
		git_files.select(idx, false)

func _on_SelUntracked_pressed():
	git_files.unselect_all()
	for idx in range(git_files.get_item_count()):
		if git_files.get_item_metadata(idx) == '?':
			git_files.select(idx, false)

func _on_SelNone_pressed():
	git_files.unselect_all()