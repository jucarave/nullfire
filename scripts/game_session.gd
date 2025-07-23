class_name GameSession

static var instance: GameSession

var score: int = 0                       # The player's score in their game session

static func get_instance() -> GameSession:
	if instance == null:
		instance = GameSession.new()
	
	return instance
