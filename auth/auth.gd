class_name Auth extends Node

const PORT: int = 31419
const BINDING: String = "127.0.0.1"
const authorization_url: String = "https://discord.com/oauth2/authorize"
const token_info_url: String = "https://discord.com/api/oauth2/@me"
const token_request_url: String = "https://discord.com/api/oauth2/token"
const token_revoke_url: String = "https://discord.com/api/oauth2/token/revoke"

var success_page_path: String = "res://auth/success.html"
var error_page_path: String = "res://auth/error.html"

var redirect_server: TCPServer = TCPServer.new()
var redirect_uri: String = "http://%s:%s/callback" % [BINDING, PORT]

#var scope: Dictionary = { "discord": "identify guilds guilds.members.read" }
var scope: Dictionary = { "discord": "guilds.members.read" }

signal token_recieved


func _init() -> void:
	SettingsManager.register_setting("auth_token", "", "discord_auth")
	SettingsManager.register_setting("refresh_token", "", "discord_auth")


func _ready():
	set_process(false)


func authorize():
	if not await is_token_valid():
		if not await refresh_tokens():
			get_auth_code()


func _process(_delta):
	# Continuously check the global JS variables set by the popup/redirect
	if OS.has_feature("web"):
		var code = JavaScriptBridge.eval("window.discordAuthCode", true)
		var state = JavaScriptBridge.eval("window.discordAuthState", true)
		
		if code and code != "null" and code != "":
			print("Successfully captured code in main game: ", code)
			set_process(false) # Stop monitoring
			# Close the popup window via JS if needed
			# JavaScriptBridge.eval("if(window.authPopup) { window.authPopup.close(); window.authPopup = null; }", true)
			# Proceed with your backend exchange
			get_token_from_auth(code)
	elif redirect_server.is_connection_available():
		var connection = redirect_server.take_connection()
		connection.poll()
		var request = connection.get_string(connection.get_available_bytes())
		if request:
			set_process(false)
			
			var parameters_dict: Dictionary = parse_parameters(request)
			
			if parameters_dict.has("error"):
				connection.put_data(generate_http_response(error_page_path, "200 OK"))
			elif parameters_dict.has("code"):
				get_token_from_auth(parameters_dict.code)
				connection.put_data(generate_http_response(success_page_path, "200 OK"))
			
			connection.disconnect_from_host()
			redirect_server.stop()


func parse_parameters(_parameters: String) -> Dictionary:
	var start_index = _parameters.find("?") + 1
	var parameters = _parameters.substr(start_index, _parameters.find(" ", start_index) - start_index)
	var parameter_array = parameters.split("&")
	
	var parameters_dict = {}
	for p in parameter_array:
		if p.find("="):
			parameters_dict[p.split("=")[0]] = p.split("=")[1]
	
	return parameters_dict


func generate_http_response(_html_file_path: String, _error_code: String) -> PackedByteArray:
	var html_content = FileAccess.get_file_as_string(_html_file_path)
	
	var response_headers = [
		"HTTP/1.1 %s" % _error_code,
		"Content-Length: " + str(html_content.length()),
		"Content-Type: text/html; charset=UTF-8",
	]
	
	var http_response = ""
	for header in response_headers:
		http_response += header + "\r\n"
	
	http_response += "\r\n" + html_content
	
	# Send the response to the client
	return http_response.to_utf8_buffer()


func get_auth_code():
	set_process(true)
	
	@warning_ignore("unused_variable")
	var redir_err = redirect_server.listen(PORT, BINDING)
	
	var body_parts = [
		"client_id=%s" % OS.get_environment("DISCORD_CLIENT_ID"),
		"redirect_uri=%s" % redirect_uri,
		"response_type=code",
		"scope=%s" % scope.discord,
		# "prompt=none" # I'm not sure how this is used or needed
	]
	if OS.has_feature("web"):
		body_parts[1] = "redirect_uri=https://verage.itch.io/vacl"
	var url = authorization_url + "?" + "&".join(body_parts)
	
	print("have javascript? %s" % OS.has_feature("web"))
	if OS.has_feature("web"):
		# Use JavaScript to open a controlled pop-up window
		# We store the reference in a JS variable so we can close it later.
		JavaScriptBridge.eval("""
			window.authPopup = window.open('%s', 'DiscordOAuth', 'width=500,height=700');
		""" % url, true)
	else:
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
	var response_code = response[1]
	
	if response_code == 200:
		SettingsManager.set_value("auth_token", response_body["access_token"], "discord_auth")
		SettingsManager.set_value("refresh_token", response_body["refresh_token"], "discord_auth")
		emit_signal("token_recieved")
	else:
		print("get_token_from_auth failed")


func refresh_tokens():
	print("refreshing token")
	var headers = [
		"Content-Type: application/x-www-form-urlencoded"
	]
	
	var body_parts = [
		"client_id=%s" % OS.get_environment("DISCORD_CLIENT_ID"),
		"client_secret=%s" % OS.get_environment("DISCORD_CLIENT_SECRET"),
		"refresh_token=%s" % SettingsManager.get_value("refresh_token", "discord_auth"),
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
	
	if response_body.has("access_token"):
		SettingsManager.set_value("auth_token", response_body["access_token"], "discord_auth")
		SettingsManager.set_value("refresh_token", response_body["refresh_token"], "discord_auth")
		print("token refreshed")
		emit_signal("token_recieved")
		return true
	else:
		return false


func is_token_valid() -> bool:
	if not SettingsManager.get_value("auth_token", "discord_auth"):
		await get_tree().create_timer(0.001).timeout
		return false
	
	var headers = [
		"Content-Type: application/x-www-form-urlencoded",
		"Authorization: Bearer %s" % SettingsManager.get_value("auth_token", "discord_auth")
	]
	
# warning-ignore:return_value_discarded
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var error = http_request.request(token_info_url, headers, HTTPClient.METHOD_GET, "")
	if error != OK:
		push_error("An error occurred in the HTTP request with ERR Code: %s" % error)
	
	var response = await http_request.request_completed
	var response_code = response[1]
	
	if response_code == 200:
		var response_json = JSON.parse_string(PackedByteArray(response[3]).get_string_from_utf8())
		
		if response_json.has("expires"):
			print("expires on %s" % response_json.expires)
			var expiration_time = Time.get_unix_time_from_datetime_string(response_json.expires)
			var current_time = Time.get_unix_time_from_system()
			
			if expiration_time > current_time:
				print("token is valid")
				token_recieved.emit()
				return true
	
	return false


func get_user_info() -> Dictionary:
	return await make_api_call("https://discord.com/api/users/@me")


func get_user_guilds() -> Dictionary:
	return await make_api_call("https://discord.com/api/users/@me/guilds")


func get_user_roles(_guild_id: String) -> Dictionary:
	return await make_api_call("https://discord.com/api/users/@me/guilds/%s/member" % _guild_id)


func revoke_token() -> void:
	# https://discord.com/developers/docs/topics/oauth2#authorization-code-grant-token-revocation-example
	print("revoking")
	var headers = [
		"Content-Type: application/x-www-form-urlencoded"
	]
	
	var body_parts = [
		"client_id=%s" % OS.get_environment("DISCORD_CLIENT_ID"),
		"client_secret=%s" % OS.get_environment("DISCORD_CLIENT_SECRET"),
		"token=%s" % SettingsManager.get_value("auth_token", "discord_auth"),
		"token_type_hint=access_token"
	]
	var body = "&".join(body_parts)
	
# warning-ignore:return_value_discarded
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var error = http_request.request(token_revoke_url, headers, HTTPClient.METHOD_POST, body)

	if error != OK:
		push_error("An error occurred in the HTTP request with ERR Code: %s" % error)
	
	var response = await http_request.request_completed
	
	var response_body = JSON.parse_string(response[3].get_string_from_utf8())
	
	if response_body:
		print(response_body)
	SettingsManager.reset_value_to_default("auth_token", "discord_auth")
	SettingsManager.reset_value_to_default("refresh_token", "discord_auth")


func make_api_call(_api_endpoint: String) -> Dictionary:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var headers = ["Authorization: Bearer %s" % SettingsManager.get_value("auth_token", "discord_auth")]
	http_request.request(_api_endpoint, headers)
	var response = await http_request.request_completed
	
	var data = JSON.parse_string(response[3].get_string_from_utf8())
	return data
