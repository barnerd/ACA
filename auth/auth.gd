class_name Auth extends Node

const PORT: int = 31419
const BINDING: String = "127.0.0.1"
const authorization_url: String = "https://discord.com/oauth2/authorize"
const token_request_url: String = "https://discord.com/api/oauth2/token"
const token_revoke_url: String = "https://discord.com/api/oauth2/token/revoke"

var redirect_server: TCPServer = TCPServer.new()
var redirect_uri: String = "http://%s:%s/callback" % [BINDING, PORT]
#var scope: Dictionary = { "discord": "identify guilds guilds.members.read" }
var scope: Dictionary = { "discord": "guilds.members.read" }
var token
var refresh_token

signal token_recieved


func _ready():
	set_process(false)


func authorize():
	# TODO: load token
	#load_tokens()
	
	if not token:
		get_auth_code()
	elif not await is_token_valid():
		if not await refresh_tokens():
			get_auth_code()


func _process(_delta):
	if redirect_server.is_connection_available():
		var connection = redirect_server.take_connection()
		var request = connection.get_string(connection.get_available_bytes())
		if request:
			set_process(false)
			# TODO: Handle if the user rejected authorization
			# error=access_denied
			# error_description=The+resource+owner+or+authorization+server+denied+the+request
			# success is:
			# code={code}
			
			# TODO: Change to REGEX
			var auth_code = request.split(" ")[1].split("=")[1]
			print("auth code: %s" % auth_code)
			get_token_from_auth(auth_code)
			
			connection.put_data(("HTTP/1.1 %d\r\n" % 200).to_ascii_buffer())
			#connection.put_data(load_HTML("res://OAuth2/display_page.html").to_ascii_buffer())
			redirect_server.stop()


func get_auth_code():
	set_process(true)
# warning-ignore:unused_variable
	var redir_err = redirect_server.listen(PORT, BINDING)
	
	var body_parts = [
		"client_id=%s" % OS.get_environment("DISCORD_CLIENT_ID"),
		"redirect_uri=%s" % redirect_uri,
		"response_type=code",
		"scope=%s" % scope.discord,
	]
	var url = authorization_url + "?" + "&".join(body_parts)
	
# warning-ignore:return_value_discarded
	OS.shell_open(url) # Opens window for user authentication


func get_token_from_auth(auth_code):
	var headers = [
		"Content-Type: application/x-www-form-urlencoded"
	]
	headers = PackedStringArray(headers)
	
	var body_parts = [
		"code=%s" % auth_code, 
		"client_id=%s" % OS.get_environment("DISCORD_CLIENT_ID"),
		"client_secret=%s" % OS.get_environment("DISCORD_CLIENT_SECRET"),
		"redirect_uri=%s" % redirect_uri,
		"grant_type=authorization_code"
	]
	
	var body = "&".join(body_parts)
	
# warning-ignore:return_value_discarded
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var error = http_request.request(token_request_url, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("An error occurred in the HTTP request with ERR Code: %s" % error)
	
	var response = await http_request.request_completed
	var response_body = JSON.parse_string(response[3].get_string_from_utf8())
	
	token = response_body["access_token"]
	refresh_token = response_body["refresh_token"]
	print({"token": token, "refresh_token": refresh_token})
	
	# TODO: Save token
	#save_tokens()
	emit_signal("token_recieved")


func refresh_tokens():
	print("refreshing")
	var headers = [
		"Content-Type: application/x-www-form-urlencoded"
	]
	
	var body_parts = [
		"client_id=%s" % OS.get_environment("DISCORD_CLIENT_ID"),
		"client_secret=%s" % OS.get_environment("DISCORD_CLIENT_SECRET"),
		"refresh_token=%s" % refresh_token,
		"grant_type=refresh_token"
	]
	var body = "&".join(body_parts)
	
# warning-ignore:return_value_discarded
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var error = http_request.request(token_request_url, headers, HTTPClient.METHOD_POST, body)

	if error != OK:
		push_error("An error occurred in the HTTP request with ERR Code: %s" % error)
	
	var response = await http_request.request_completed
	
	var response_body = JSON.parse_string(response[3].get_string_from_utf8())
	
	if response_body.get("access_token"):
		token = response_body["access_token"]
		# TODO: Save token
		#save_tokens()
		print("token refreshed")
		emit_signal("token_recieved")
		return true
	else:
		return false


func is_token_valid() -> bool:
	if !token:
		await get_tree().create_timer(0.001).timeout
		return false
	
	var headers = [
		"Content-Type: application/x-www-form-urlencoded"
	]
	
	var body = "access_token=%s" % token
# warning-ignore:return_value_discarded
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var error = http_request.request(token_request_url + "info", headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("An error occurred in the HTTP request with ERR Code: %s" % error)
	
	var response = await http_request.request_completed
	
	var expiration = JSON.parse_string(response[3].get_string_from_utf8())["expires_in"]
	
	if expiration and int(expiration) > 0:
		print(expiration)
		print("token is valid")
		emit_signal("token_recieved")
		return true
	else:
		return false


func get_user_info() -> Dictionary:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var headers = ["Authorization: Bearer %s" % token]
	http_request.request("https://discord.com/api/users/@me", headers)
	var response = await http_request.request_completed
	var data = JSON.parse_string(response[3].get_string_from_utf8())
	return data


func get_user_guilds() -> Dictionary:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var headers = ["Authorization: Bearer %s" % token]
	http_request.request("https://discord.com/api/users/@me/guilds", headers)
	var response = await http_request.request_completed
	var data = JSON.parse_string(response[3].get_string_from_utf8())
	return data


func get_user_roles(_guild_id: String) -> Array:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var headers = ["Authorization: Bearer %s" % token]
	http_request.request("https://discord.com/api/users/@me/guilds/%s/member" % _guild_id, headers)
	var response = await http_request.request_completed
	var data = JSON.parse_string(response[3].get_string_from_utf8())
	return data.roles


# SAVE/LOAD
#const SAVE_DIR = 'user://token/'
#var save_path = SAVE_DIR + 'token.dat'


#func save_tokens():
	#var dir = DirAccess.open(SAVE_DIR)
	#if !dir:
		#dir.make_dir_recursive(SAVE_DIR)
	#
	#var file = File.new()
	#var error = file.open_encrypted_with_pass(save_path, File.WRITE, 'abigail')
	#if error == OK:
		#var tokens = {
			#"token" : token,
			#"refresh_token" : refresh_token
		#}
		#file.store_var(tokens)
		#file.close()


#func load_tokens():
	#var file = File.new()
	#if file.file_exists(save_path):
		#var error = file.open_encrypted_with_pass(save_path, File.READ, 'abigail')
		#if error == OK:
			#var tokens = file.get_var()
			#token = tokens.get("token")
			#refresh_token = tokens.get("refresh_token")
			#file.close()
			#print("token loaded successfully")


#func load_HTML(path):
	#var file = File.new()
	#if file.file_exists(path):
		#file.open(path, File.READ)
		#var HTML = file.get_as_text().replace("    ", "\t").insert(0, "\n")
		#file.close()
		#return HTML
