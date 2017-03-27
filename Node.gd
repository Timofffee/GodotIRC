extends Node


var ip = "weber.freenode.net"
var client
var nick = "GodotIRC"
var channel = "#godotengine_ru"
var password = ""

var time

var lt = RichTextLabel.new()

func _ready():
	_on_time_updater_timeout()
	client = StreamPeerTCP.new()
	client.connect(ip, 6667)
	if password != "":
		client.put_data(("JOIN "+ password +"\n").to_utf8())
	client.put_data(("USER "+ nick +" "+ nick +" "+ nick +" :TEST\n").to_utf8())
	client.put_data(("NICK "+ nick +"\n").to_utf8())
	client.put_data(("JOIN "+ channel +"\n").to_utf8())
	set_fixed_process(true)

func _fixed_process(delta):
	if client.is_connected() && client.get_available_bytes() >0:
		
		var a = str(client.get_utf8_string(client.get_available_bytes()))
		a = a.split('\n')
		for b in a:
			b = b.split(' ')
			if b.size() > 1:
				if b[0] == "PING":
					client.put_data(("PONG "+ str(b[1]) +"\n").to_utf8())
				elif b[1] == "NOTICE":
					var text = ""
					for i in range (4, b.size()):
						text += b[i] + " "
					get_node("text").append_bbcode("[" + time + "][i] [color=green]SERVER:[/color] " + text + "[/i]\n")
				elif b[1] == "JOIN":
					get_node("text").append_bbcode("[" + time + "][i] [color=red]==[/color] " + get_name_user(b[0]) + " has joined " + str(channel) + "[/i]\n")
				elif b[1] == "QUIT":
					var text = ""
					for i in range (4, b.size()):
						text += b[i] + " "
					get_node("text").append_bbcode("[" + time + "][i] == " + get_name_user(b[0]) + " QUIT (" + str(text) + ")[/i]\n")
				elif b[1] == "PART":
					get_node("text").append_bbcode("[" + time + "][i] == " + get_name_user(b[0]) + " has left " + str(channel) + "[/i]\n")
				elif b[1] == "PRIVMSG":
					var text = ""
					for i in range (3, b.size()):
						text += b[i] + " "
					text = text.substr(1, text.length()-1)
					lt.clear()
					lt.append_bbcode(text)
					get_node("text").append_bbcode("[" + time + "] <" + get_name_user(b[0]) + "> " + str(text) + "\n")



func get_name_user (value):
	var a = value.find("!")
	return value.substr(1, a-1)

func _on_enterLine_text_entered( text ):
	lt.clear()
	lt.append_bbcode(text)
	get_node("text").append_bbcode("[" + time + "] <" + nick + "> " + str(lt.get_text()) + "\n")
	client.put_data(("PRIVMSG "+ channel + " :" + str(lt.get_text()) +"\n").to_utf8())
	get_node("enterLine").clear()

func _on_Button_pressed():
	_on_enterLine_text_entered(get_node("enterLine").get_text())


func _on_time_updater_timeout():
	time = ""
	if OS.get_time().hour < 10:
		time += "0"
	time += str(OS.get_time().hour) + ":"
	
	if OS.get_time().minute < 10:
		time += "0"
	time += str(OS.get_time().minute) + ":"
	
	if OS.get_time().second < 10:
		time += "0"
	time += str(OS.get_time().second)
