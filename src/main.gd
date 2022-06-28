class_name Main
extends Control

var following := false
var start_pos := Vector2.ZERO

var cardsets := []
export(NodePath) var _row
onready var row = get_node(_row)


func _ready() -> void:
  OS.window_resizable = true
  if OS.window_fullscreen:
    fullscreen_pressed()
  else:
    shrink_pressed()
  
  var file = File.new()
  file.open("res://data/cardsets.php", file.READ)
  var text = file.get_as_text()
  file.close()
  var parse := JSON.parse(text)
  if parse.error == OK:
    cardsets = parse.result
    # Default to sort by date
    cardsets.sort_custom(self, "sort_by_date_desc")
    form_cardsets(cardsets)
  else:
    # TODO: show error
    print("Error.")
  

func form_cardsets(cardsets:Array) -> void:
  for cardset in cardsets:
    var new_row = row.duplicate()
    new_row.connect("pressed", self, "cardset_pressed", [cardset.set_code])
    
    var name : Label = new_row.get_node('Data/Name')
    var code : Label = new_row.get_node('Data/Code')
    var collected : Label = new_row.get_node('Data/Collected')
    var percentage : Label = new_row.get_node('Data/Percentage')
    var release_date : Label = new_row.get_node('Data/ReleaseDate')
    
    name.text = Stringify.ellipse(cardset.set_name)
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
  print("here")
  print(set_code)


func minimize_pressed() -> void:
  OS.window_minimized = true


func fullscreen_pressed() -> void:
  OS.window_fullscreen = true
  $Doc/Header/Margin/List/SysNav/Shrink.show()
  $Doc/Header/Margin/List/SysNav/Fullscreen.hide()
  

func shrink_pressed() -> void:
  OS.window_fullscreen = false
  $Doc/Header/Margin/List/SysNav/Shrink.hide()
  $Doc/Header/Margin/List/SysNav/Fullscreen.show()

func exit_pressed() -> void:
  get_tree().quit()
