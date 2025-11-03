#network handler
extends Node

const IP_ADDRESS: String = "localhost"
const PORT: int = 9999

var peer: ENetMultiplayerPeer

func start_server() -> void:
	peer = ENetMultiplayerPeer.new()
	var res = peer.create_server(PORT)
	
	if res == OK:
		print("Connected")
	else:
		print("Failed: ", res)
	multiplayer.multiplayer_peer = peer

func start_client() -> void:
	peer = ENetMultiplayerPeer.new()
	var res = peer.create_client(IP_ADDRESS, PORT)
	
	if res == OK:
		print("Connected")
	else:
		print("Failed: ", res)
	multiplayer.multiplayer_peer = peer
	
