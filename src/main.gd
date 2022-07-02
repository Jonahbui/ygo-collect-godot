class_name Main
extends Control

export(NodePath) var _row
onready var row = get_node(_row)

var sort : String = "date"
var sort_dir : String = "desc"

var set_outlines := []

var is_set_forming := true

func _ready() -> void:
  Info.sets.sort_custom(Info, "sort_set_by_date_desc")
  form_cardsets(Info.sets)
  
  $Doc/Index.show()
  $Doc/CardDisplay.hide()
  $Doc/CardDisplay/List.show()
  $Doc/CardDisplay/FullView.hide()
  $Doc/Settings.hide()
  


func form_cardsets(sets:Array) -> void:
  $AnimationPlayer.play("loading")
  for set in sets:
    var new_row : Button = row.duplicate()
    $Doc/Index/Body/TableBackground/Table/Margin/Body.call_deferred('add_child', new_row)
    yield(get_tree(), "idle_frame")
    new_row.connect("pressed", self, "cardset_pressed", [set.set_name])
    new_row.name = "Row-%s" % [set.set_code]
    new_row.set_name.text = set.set_name
    new_row.code.text = set.set_code
    var cards_collected := 0
    var num_of_cards := int(set.num_of_cards)
    new_row.collected.text = "%-7s" % ['{a}/{b}'.format({'a':cards_collected, 'b':num_of_cards})]
    new_row.percentage.text = "%0.0f" % [ cards_collected/num_of_cards ]
    new_row.release_date.text = set.tcg_date
    set_outlines.append(new_row)
  $Doc/Index/Body/TableBackground/Table/Loading.hide()
  for set_outline in set_outlines:
    set_outline.show()
  is_set_forming = false

func cardset_pressed(selected_set_name:String) -> void:
  $Doc/CardDisplay.form_set(selected_set_name)
  $Doc/Index.hide()


func cardset_back_pressed() -> void:
  $Doc/CardDisplay.hide()
  $Doc/Index.show()


func settings_pressed():
  pass # Replace with function body.


func slide_out_pressed():
  $AnimationPlayer.play("slide_out")


func slide_in_pressed():
  $AnimationPlayer.play("slide_in")


func _card_type_pressed(type:String) -> void:
  match type:
    "All":
      pass
    "Spells":
      pass
    "Traps":
      pass
    "Normals":
      pass
    "Effects":
      pass
    "Rituals":
      pass
    "Fusions":
      pass
    "Synchros":
      pass
    "XYZs":
      pass
    "Pendelums":
      pass
    "Links":
      pass


func _monsters_toggled(state:bool) -> void:
  if state:
    $AnimationPlayer.play("show_monsters")
  else:
    $AnimationPlayer.play("hide_monsters")


func _search_text_changed(text:String) -> void:
  # Do not allow searching if sets are still being created
  if is_set_forming:
    return
  yield(get_tree().create_timer(1), "timeout")
  if text != $Doc/Index/Body/TableBackground/Table/SearchBar.text:
    return
  
    for set_outline in set_outlines:
      set_outline.hide()
      
    return

  text = text.to_lower()
  if text.empty():
    for set_outline in set_outlines:
      set_outline.show()
  else:
    for set_outline in set_outlines:
      if text in set_outline.set_name.text.to_lower() or text in set_outline.code.text.to_lower():
        set_outline.show()
      else:
        set_outline.hide()
  
