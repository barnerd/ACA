extends Control

# roles:
const FORSAKEN_ROLE_ID: String = "530756694922231819"
const FORSAKEN_CLASSIFIED_ROLE_ID: String = "633354201577160749"
const FORSAKEN_MAYOR_ROLE_ID: String = "1186214591227768902"

const AGONIA_SERVER_ID: String = "530750959719284787"

@onready var auth_node: Auth = $AuthNode

var logged_in_user: String

signal user_logged_in(_name: String)


func _init() -> void:
	SignalBus.register_signal("user_logged_in", user_logged_in)
	
	Dotenv.load_("res://discord.env", false, true)


func _on_button_pressed() -> void:
	auth_node.token_recieved.connect(_on_token_recieved)
	auth_node.authorize()


func _on_token_recieved() -> void:
	#var user = await auth_node.get_user_info()
	#var user_guilds = await auth_node.get_user_guilds()
	var user_roles = await auth_node.get_user_roles(AGONIA_SERVER_ID)
	
	if user_roles.nick:
		print("user_name: %s" % user_roles.nick)
		logged_in_user = user_roles.nick
	else:
		print("user_name: %s" % user_roles.user.global_name)
		logged_in_user = user_roles.user.global_name
	
	user_logged_in.emit(logged_in_user)
	
	print("roles:")
	print(user_roles.roles)
	if user_roles.roles.has(FORSAKEN_ROLE_ID):
		print("Member is forsaken!")
