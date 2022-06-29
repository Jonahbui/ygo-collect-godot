class_name Main
extends Control

var following := false
var start_pos := Vector2.ZERO

var cardsets := []
export(NodePath) var _row
onready var row = get_node(_row)

var current_set : String = ""

var cards = null

func _ready() -> void:
  OS.window_resizable = true
  if OS.window_fullscreen:
    fullscreen_pressed()
  else:
    shrink_pressed()
  
  var dir = Directory.new()
  dir.open("user://")
  dir.make_dir("data")
  dir.make_dir("images")
  var set_parse = Parse.read_json("user://data/cardsets.php")
  if set_parse:
    cardsets = set_parse.result
    cardsets.sort_custom(self, "sort_by_date_desc")
    form_cardsets(cardsets)
  else:
    # TODO: show error
    print("Error.")

  var all_cards_parse = Parse.read_json("user://data/cardinfo.php")
  if all_cards_parse:
    cards = all_cards_parse.result["data"]
  else:
    print("Error.")


func form_cardsets(cardsets:Array) -> void:
  for cardset in cardsets:
    var new_row : Button = row.duplicate()
    new_row.connect("pressed", self, "cardset_pressed", [cardset.set_code])
    new_row.name = "Row-%s" % [cardset.set_code]
    var name : Label = new_row.get_node('Data/Name')
    var code : Label = new_row.get_node('Data/Code')
    var collected : Label = new_row.get_node('Data/Collected')
    var percentage : Label = new_row.get_node('Data/Percentage')
    var release_date : Label = new_row.get_node('Data/ReleaseDate')
    
    name.text = cardset.set_name
    code.text = cardset.set_code
    var cards_collected := 0
    var num_of_cards := int(cardset.num_of_cards)
    collected.text = "%-7s" % ['{a}/{b}'.format({'a':cards_collected, 'b':num_of_cards})]
    percentage.text = "%0.0f" % [ cards_collected/num_of_cards ]
    release_date.text = cardset.tcg_date if cardset.has('tcg_date') else 'Unknown'
    row.get_parent().call_deferred('add_child', new_row)
    new_row.show()


static func sort_by_date(a:Dictionary,b:Dictionary) -> bool:
  if not a.has('tcg_date'):
    return true
  if not b.has('tcg_date'):
    return false
  return a.tcg_date < b.tcg_date


static func sort_by_date_desc(a:Dictionary, b:Dictionary) -> bool:
  if not a.has('tcg_date'):
    return false
  if not b.has('tcg_date'):
    return true
  return a.tcg_date > b.tcg_date


func header_gui_input(event:InputEvent) -> void:
  if event is InputEventMouseButton:
    if event.get_button_index() == 1:
      following = event.pressed
      start_pos = event.position
  if following:
    OS.set_window_position(OS.window_position+event.position-start_pos)


func cardset_pressed(set_code:String) -> void:
  var selected_cardset := {}
  for cardset in cardsets:
    if cardset.set_code == set_code:
      selected_cardset = cardset
      break

  current_set = set_code
  $Doc/CardsetBody.show()
  $Doc/IndexBody.hide()
  print("Processing cards for set %s" % [set_code])
  var cards_in_set := []
  for card in cards:
    if not card.has("card_sets"):
      continue
    for card_set in card.card_sets:
      if card_set.set_code.substr(0,4) == current_set:
        cards_in_set.append(card)
  $Doc/CardsetBody.form_set(selected_cardset, cards_in_set)


func minimize_pressed() -> void:
  OS.window_minimized = true


func fullscreen_pressed() -> void:
  OS.window_maximized = true
  $Doc/Header/Margin/List/SysNav/Shrink.show()
  $Doc/Header/Margin/List/SysNav/Fullscreen.hide()


func shrink_pressed() -> void:
  OS.window_maximized = false
  $Doc/Header/Margin/List/SysNav/Shrink.hide()
  $Doc/Header/Margin/List/SysNav/Fullscreen.show()

func exit_pressed() -> void:
  get_tree().quit()


func cardset_back_pressed() -> void:
  $Doc/CardsetBody.hide()
  $Doc/IndexBody.show()


func settings_pressed():
  pass # Replace with function body.
