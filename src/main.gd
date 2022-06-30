class_name Main
extends Control

var following := false
var start_pos := Vector2.ZERO

export(NodePath) var _row
onready var row = get_node(_row)

var current_set : String = ""

func _ready() -> void:
  Info.sets.sort_custom(Info, "sort_set_by_date_desc")
  form_cardsets(Info.sets)


func form_cardsets(sets:Array) -> void:
  for set in sets:
    var new_row : Button = row.duplicate()
    new_row.connect("pressed", self, "cardset_pressed", [set.set_name])
    new_row.name = "Row-%s" % [set.set_code]
    var name : Label = new_row.get_node('Data/Name')
    var code : Label = new_row.get_node('Data/Code')
    var collected : Label = new_row.get_node('Data/Collected')
    var percentage : Label = new_row.get_node('Data/Percentage')
    var release_date : Label = new_row.get_node('Data/ReleaseDate')
    
    name.text = set.set_name
    code.text = set.set_code
    var cards_collected := 0
    var num_of_cards := int(set.num_of_cards)
    collected.text = "%-7s" % ['{a}/{b}'.format({'a':cards_collected, 'b':num_of_cards})]
    percentage.text = "%0.0f" % [ cards_collected/num_of_cards ]
    release_date.text = set.tcg_date
    row.get_parent().call_deferred('add_child', new_row)
    new_row.show()

func header_gui_input(event:InputEvent) -> void:
  if event is InputEventMouseButton:
    if event.get_button_index() == 1:
      following = event.pressed
      start_pos = event.position
  if following:
    OS.set_window_position(OS.window_position+event.position-start_pos)


func cardset_pressed(selected_set_name:String) -> void:
  # Find and update the current card set being viewed
  var selected_cardset : Set 
  for set in Info.sets:
    if set.set_name == selected_set_name:
      selected_cardset = set
      break
  current_set = selected_set_name

  # Find the cards for that selected set
  $Doc/CardDisplay.show()
  $Doc/IndexBody.hide()
  print("Processing cards for set %s" % [selected_set_name])
  var cards_in_set := []
  for card in Info.cards:
    # The sets that the card could be in
    for card_set in card.card_sets:
      if card_set.set_name == selected_set_name:
        cards_in_set.append(card)
  $Doc/CardDisplay.form_set(selected_cardset, cards_in_set)


func cardset_back_pressed() -> void:
  $Doc/CardDisplay.hide()
  $Doc/IndexBody.show()


func settings_pressed():
  pass # Replace with function body.
