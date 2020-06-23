extends Sprite

onready  var label_news = get_node("label_news")
onready  var label_page = get_node("label_page")
onready  var arrow_left = get_node("arrow_left")
onready  var arrow_right = get_node("arrow_right")
onready  var button_steam = get_node("button_steam")
onready  var button_discord = get_node("button_discord")

var max_pages = 6
var curr_page = 1

func _process(delta):
	if Input.is_action_just_pressed("player1_left"):
		curr_page -= 1
		if curr_page < 1:
			curr_page = 1
	if Input.is_action_just_pressed("player1_right"):
		curr_page += 1
		if curr_page > max_pages:
			curr_page = max_pages
	set_page()

func set_page():
	var news_text = ""
	arrow_left.visible = true
	arrow_right.visible = true
	if curr_page == 1:
		arrow_left.visible = false
	elif curr_page == max_pages:
		arrow_right.visible = false
	match curr_page:
		1:
			news_text = """
(2/26/20) v2.3 \"Party Time\" is now available!
Features:
- 8 player lobbies!!
- Lobby rematch and rotation settings
- Find Lobby feature (replacing Quick Match)
- Keyword for finding private lobbies
More details on Steam and Discord!
"""
		2:
			news_text = """
(1/27/20) v2.2 \"Ignition\" is now available!
Features:
- Auto delay setting for Quick Match and
  Friend Lobby
- Millisecond counter for Arcade Mode times
- Slight rebalancing and more bugfixes
More details on Steam and Discord!
"""
		3:
			news_text = """
(12/23/19) v2.1 \"Infinite\" is now available!
Features:
- Reworked collision system and hitboxes
  (should eliminate network desyncs)
- Shorter time between rounds
- Increased dash recovery time
- Rebalanced all characters
(Continued...)
"""
		4:
			news_text = """
- New moves for Dr. Kero: Tongue Shot,
  Spit Back, Swallow, and Super Swallow
- A Christmas secret! (lasts until Dec. 31st)
- Plenty of bugfixes!
More details on Steam and Discord!
"""
		5:
			news_text = """
(9/14/19) v2.0 \"Unlimited\" is now available!
Features:
- Renamed to simply HYPERFIGHT
  (v1.x codenamed \"Max Battle\")
- Added online multiplayer
- New character: Vince Volt
- New stage + music: Sunset Bridge
(Continued...)
"""
		6:
			news_text = """
- Major UI rehaul
- New moves for Shoto Goto, Dark Goto,
  and Don McRon
- Rebalanced physics and all characters
- Move lists in pause menu
- CPU vs CPU mode
- CPU difficulty option (Normal by default)
- Vsync option (On by default)
More details on Steam and Discord!
"""
	
	label_page.text = str(curr_page) + "/" + str(max_pages)
	label_news.text = news_text

func set_active(active):
	button_steam.activated = active
	button_discord.activated = active
