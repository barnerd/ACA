extends Button

# roles:
const FORSAKEN_ROLE_ID: String = "530756694922231819"
const FORSAKEN_CLASSIFIED_ROLE_ID: String = "633354201577160749"
const FORSAKEN_MAYOR_ROLE_ID: String = "1186214591227768902"

const AGONIA_SERVER_ID: String = "530750959719284787"

@onready var auth_node = $"../AuthNode"

var logged_in_user: String

signal user_logged_in(_name: String, _is_forsaken: bool)


func _init() -> void:
	SignalBus.register_signal("user_logged_in", user_logged_in)
	
	Dotenv.load_("res://discord.env", false, true)


func _ready() -> void:
	SignalBus.connect_to_signal("user_logged_out", on_user_logged_out)
	
	auth_node.token_recieved.connect(_on_token_recieved)
	
	$"../StatusLabel".text = "Attempting to login..."
	if not await auth_node.is_token_valid():
		if not await auth_node.refresh_tokens():
			print("user is not logged in")
			$"../StatusLabel".text = "Please login"


func _on_pressed() -> void:
	auth_node.authorize()


func _on_token_recieved() -> void:
	$"../StatusLabel".text = "Logged in..."
	#var user = await auth_node.get_user_info()
	#var user_guilds = await auth_node.get_user_guilds()
	var user_roles = await auth_node.get_user_roles(AGONIA_SERVER_ID)
	
	if user_roles.nick:
		logged_in_user = user_roles.nick
	else:
		logged_in_user = user_roles.user.global_name
	
	var is_forsaken = user_roles.roles.has(FORSAKEN_ROLE_ID)
	if is_forsaken:
		print("Member is forsaken!")
		$"../StatusLabel".text = "Welcome back, %s" % logged_in_user
		$"../LoadAgonia".visible = true
	else:
		$"../StatusLabel".text = "Sorry, Forsaken only"
	
	self.visible = false
	user_logged_in.emit(logged_in_user, is_forsaken)


func on_user_logged_out() -> void:
	self.visible = true
