extends Control

# roles:
const FORSAKEN_ROLE_ID: String = "530756694922231819"
const FORSAKEN_CLASSIFIED_ROLE_ID: String = "633354201577160749"
const FORSAKEN_MAYOR_ROLE_ID: String = "1186214591227768902"

const AGONIA_SERVER_ID: String = "530750959719284787"

@onready var auth_node: Auth = $AuthNode

func _init() -> void:
	Dotenv.load_("res://discord.env", false, true)

func _on_button_pressed() -> void:
	auth_node.token_recieved.connect(_on_token_recieved)
	auth_node.authorize()


func _on_token_recieved() -> void:
	print("We have it!")
	
	#var user = await auth_node.get_user_info()
	#print("user:")
	#print(user)
	#var user_guilds = await auth_node.get_user_guilds()
	var user_roles = await auth_node.get_user_roles(AGONIA_SERVER_ID)
	print("roles:")
	print(user_roles)
	if user_roles.has(FORSAKEN_ROLE_ID):
		print("Member is forsaken!")
