extends Node


var ip = "weber.freenode.net"
var client
var nick = "Gloomer"
var channel = "#godotengine_ru"
var password = ""

func _ready():
	client = StreamPeerTCP.new()
	client.connect(ip, 6667)
	if password != "":
		client.put_data(("JOIN "+ password +"\n").to_ascii())
	client.put_data(("USER "+ nick +" "+ nick +" "+ nick +" :TEST\n").to_ascii())
	client.put_data(("NICK "+ nick +"\n").to_ascii())
	client.put_data(("JOIN "+ channel +"\n").to_ascii())
	set_fixed_process(true)

func _fixed_process(delta):
	if client.is_connected() && client.get_available_bytes() >0:
		var time = str(OS.get_time().hour) + ":" + str(OS.get_time().minute) + ":" + str(OS.get_time().second)
		var a = str(client.get_string(client.get_available_bytes()))
		a = a.split('\n')
		for b in a:
			b = b.split(' ')
			if b.size() > 1:
				if b[0] == "PING":
					client.put_data(("PONG "+ str(b[1]) +"\n").to_ascii())
				elif b[1] == "NOTICE":
					var text = ""
					for i in range (4, b.size()):
						text += b[i] + " "
					get_node("text").append_bbcode("[" + time + "] SERVER: " + text + "\n")
				elif b[1] == "JOIN":
					get_node("text").append_bbcode("[" + time + "] == " + get_name_user(b[0]) + " has joined " + str(channel) + "\n")
				elif b[1] == "QUIT":
					var text = ""
					for i in range (4, b.size()):
						text += b[i] + " "
					get_node("text").append_bbcode("[" + time + "] == " + get_name_user(b[0]) + " QUIT (" + str(text) + ")\n")
				elif b[1] == "PART":
					get_node("text").append_bbcode("[" + time + "] == " + get_name_user(b[0]) + " has left " + str(channel) + "\n")
				elif b[1] == "PRIVMSG":
					var text = ""
					for i in range (3, b.size()):
						text += b[i] + " "
					text = text.substr(1, text.length()-1)
					get_node("text").append_bbcode("[" + time + "] <" + get_name_user(b[0]) + "> " + str(text) + "\n")

func get_name_user (value):
	var a = value.find("!")
	return value.substr(1, a-1)

func _on_enterLine_text_entered( text ):
	var time = str(OS.get_time().hour) + ":" + str(OS.get_time().minute) + ":" + str(OS.get_time().second)
	get_node("text").append_bbcode("[" + time + "] <" + nick + "> " + str(text) + "\n")
	client.put_data(("PRIVMSG "+ channel + " :" + str(text) +"\n").to_ascii())
	get_node("enterLine").clear()

func _on_Button_pressed():
	_on_enterLine_text_entered(get_node("enterLine").get_text())
