extends Control

var following := false
var start_pos := Vector2.ZERO

var cardsets := []
export(NodePath) var _row
onready var row = get_node(_row)


func _ready() -> void:
  var file = File.new()
  file.open("res://data/cardsets.php", file.READ)
  var text = file.get_as_text()
  file.close()
  var parse := JSON.parse(text)
  if parse.error == OK:
    cardsets = parse.result
    form_cardsets(cardsets)
  else:
    # TODO: show error
    print("Error.")
  

func form_cardsets(cardsets:Array) -> void:
  for cardset in cardsets:
    var new_row = row.duplicate()
    new_row.connect("pressed", self, "carset_pressed", [cardset.set_code])
    
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


func header_gui_input(event:InputEvent) -> void:
  if event is InputEventMouseButton:
    if event.get_button_index() == 1:
      following = event.pressed
      start_pos = event.position
  if following:
    OS.set_window_position(OS.window_position+event.position-start_pos)


func cardset_pressed(set_code:String) -> void:
  print(set_code)


func exit_pressed():
  get_tree().quit()
