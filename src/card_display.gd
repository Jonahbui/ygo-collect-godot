class_name CardSet
extends Control

const DEF_CARD_IMAGE = preload("res://images/default.jpg")
const SHDR_GRAYSCALE = preload("res://src/shaders/grayscale.gdshader")

onready var grid = $List/Scroll/Margin/Grid
onready var card_template = $List/Scroll/Margin/Grid/Card

var card_outlines := []

var set: Set
var current_card := { "id": -1, "set_rarity_code": "", "outline": null}


func _ready() -> void:
  get_tree().connect("screen_resized", self, "_window_size_changed")

# TODO: sort card by setcode
func form_set(selected_set_name:String) -> void: 
  # Get the set being displayed
  self.set = Info.get_set_by_name(selected_set_name)
  
  # Display general set info
  $List/SetName.text = set.set_name
  $List/Info/CardsInSet.text = str(set.num_of_cards)
  
  # Instance more cards for display if insufficient amount currently present
  yield(create_card_outlines(set), "completed")

  # Create display 
  print("Processing cards for set %s" % [selected_set_name])
  var file := File.new()
  var i := 0
  # Fill in cards with data
  for card in Info.cards:
    # The sets that the card could be in
    for card_set in card.card_sets:
      if card_set.set_name == selected_set_name:
        # Get the card
        var card_outline : CardOutline = self.card_outlines[i]
        
        # Allow users to interact with card
        if card_outline.card_image.is_connected("pressed", self, "_card_pressed"):
          card_outline.card_image.disconnect("pressed", self, "_card_pressed")
        card_outline.card_image.connect("pressed", self, "_card_pressed", [card_outline, card.id, card_set.set_rarity_code])
        
        # TODO: actually pull numbers for the number of cards collected
        var total_quantity : int = card_set.first_editions + card_set.reprints
        
        # Display card image
        var texture = get_card_texture(card.id)
        if texture is GDScriptFunctionState:
          texture = yield(texture, "completed")
        card_outline.card_image.texture_normal = texture
        # Display card status
        card_outline.card_image.material = ShaderMaterial.new()
        if total_quantity == 0:
          card_outline.card_image.material.shader = SHDR_GRAYSCALE
        # Display name of card
        card_outline.card_name.text = card.name
        # Display card rarity
        card_outline.card_rarity.text = card_set.set_rarity_code
        
        card_outline.show()
        i += 1
        break
  file.close()
  self.show()

func get_card_texture(card_id) -> Texture:
  var file := File.new()
  var image = Image.new()
  var image_path = "%s/%s.jpg" % [Externals.CARD_IMAGES_PATH, card_id]
  if not file.file_exists(image_path):
    var image_url = "%s/%s.jpg" % [Externals.IMAGE_DB_URL, card_id]
    print("Downloading external image @ %s" % image_url)
    $HTTPRequest.set_download_file(image_path)
    $HTTPRequest.request(image_url)
    var result = yield($HTTPRequest, "request_completed")
      
    if result[0] != HTTPRequest.Result.RESULT_SUCCESS:
      # TODO: return a default picture
      print("Error. Could not download image. Result: %d. Return Code: %d" % [result[0], result[1]])
      return DEF_CARD_IMAGE
  else:
    print("Loading external image @ %s" % image_path)
    
  file.close()
  var error = image.load(image_path)
  if error != OK:
    # TODO: load a default picture
    print("Error loading image.")
    return DEF_CARD_IMAGE
  
  var texture = ImageTexture.new()
  texture.create_from_image(image, 0)
  
  return texture


func create_card_outlines(set:Set) -> void:
  # More cards than card outlines
  if set.num_of_cards > self.card_outlines.size():
    for _i in range (0, set.num_of_cards - self.card_outlines.size()):
      var new_card = card_template.duplicate()
      grid.call_deferred("add_child", new_card)
      self.card_outlines.append(new_card)
  
  # Less cards than card outlines
  elif set.num_of_cards < self.card_outlines.size():
    # Show the ones we need later; hide the rest
    for i in range(0, self.card_outlines.size()):
      self.card_outlines[i].hide()
  else:
    pass
  yield(get_tree(), "idle_frame")
  return


func _increment_first_editions():
  for card in Info.cards:
    if card.id == current_card.id:
      for card_set in card.card_sets:
        if card_set.set_name == set.set_name and card_set.set_rarity_code ==  current_card.set_rarity_code:
          card_set.reprints = int(clamp(card_set.first_editions + 1, 0 , 999))

          # Update UI to reflect new amount
          $FullView/Margin/Control/Info/First/Amount.text = "%d" % card_set.first_editions
          var total_quantity : int = card_set.first_editions + card_set.reprints
          if total_quantity > 0:
            current_card.outline.card_image.material.shader = null
          Info.save_card(card)


func _increment_reprint_editions():
  for card in Info.cards:
    if card.id == current_card.id:
      for card_set in card.card_sets:
        if card_set.set_name == set.set_name and card_set.set_rarity_code ==  current_card.set_rarity_code:
          card_set.reprints = int(clamp(card_set.reprints + 1, 0 , 999))

          # Update UI to reflect new amount
          $FullView/Margin/Control/Info/Reprint/Amount.text = "%d" % card_set.reprints
          var total_quantity : int = card_set.first_editions + card_set.reprints
          if total_quantity > 0:
            current_card.outline.card_image.material.shader = null
          Info.save_card(card)


func _decrement_first_editions():
  for card in Info.cards:
    if card.id == current_card.id:
      for card_set in card.card_sets:
        if card_set.set_name == set.set_name and card_set.set_rarity_code ==  current_card.set_rarity_code:
          card_set.reprints = int(clamp(card_set.first_editions - 1, 0 , 999))
          
          # Update UI to reflect new amount
          $FullView/Margin/Control/Info/First/Amount.text = "%d" % card_set.first_editions
          var total_quantity : int = card_set.first_editions + card_set.reprints
          if total_quantity == 0:
            current_card.outline.card_image.material.shader = SHDR_GRAYSCALE
          Info.save_card(card)


func _decrement_reprint_editions():
  for card in Info.cards:
    if card.id == current_card.id:
      for card_set in card.card_sets:
        if card_set.set_name == set.set_name and card_set.set_rarity_code ==  current_card.set_rarity_code:
          card_set.reprints = int(clamp(card_set.reprints - 1, 0 , 999))

          # Update UI to reflect new amount
          $FullView/Margin/Control/Info/Reprint/Amount.text = "%d" % card_set.reprints
          var total_quantity : int = card_set.first_editions + card_set.reprints
          if total_quantity == 0:
            current_card.outline.card_image.material.shader = SHDR_GRAYSCALE
          Info.save_card(card)


func _quantity_first_editions_changed(quantity:String):
  if not quantity.is_valid_integer():
    return
  var parse : int = quantity.to_int()
  
  for card in Info.cards:
    if card.id == current_card.id:
      for card_set in card.card_sets:
        if card_set.set_name == set.set_name and card_set.set_rarity_code ==  current_card.set_rarity_code:
          card_set.first_editions = int(clamp(parse, 0, 999))
          if card_set.first_editions == 0:
            $FullView/Margin/Control/Info/First/Amount.text = "%d" % card_set.first_editions
            
          
          # Update UI to reflect new amount
          var total_quantity : int = card_set.first_editions + card_set.first_editions
          if total_quantity == 0:
            current_card.outline.card_image.material.shader = SHDR_GRAYSCALE
          else:
            current_card.outline.card_image.material.shader = null
          Info.save_card(card)


func _quantity_reprint_editions_changed(quantity:String):
  if not quantity.is_valid_integer():
    return
  var parse : int = quantity.to_int()

  for card in Info.cards:
    if card.id == current_card.id:
      for card_set in card.card_sets:
        if card_set.set_name == set.set_name and card_set.set_rarity_code ==  current_card.set_rarity_code:
          card_set.reprints = int(clamp(parse, 0, 999))
          if card_set.reprints == 0:
            $FullView/Margin/Control/Info/First/Amount.text = "%d" % card_set.reprints

          # Update UI to reflect new amount
          var total_quantity : int = card_set.reprints + card_set.reprints
          if total_quantity == 0:
            current_card.outline.card_image.material.shader = SHDR_GRAYSCALE
          else:
            current_card.outline.card_image.material.shader = null
          Info.save_card(card)


func _window_size_changed():
  var card_x = int(card_template.rect_size.x)
  var grid_pad_x = grid.get_constant("hseparation")
  var margin_x = get_constant("margin_left") + get_constant("margin_right")
  var grid_margin_x = $List/Scroll/Margin.get_constant("margin_left") + $List/Scroll/Margin.get_constant("margin_right")
  var window_x = OS.window_size.x - margin_x - grid_margin_x
  
  # NOTE: formula for the number of columns needed to fill in the grid
  # n = floor((z + y)/(x + y))
  # where
  # n : the number of columns needed to fill a grid
  # z : the x-size of the grid
  # y : the x-size of the padding between each elemennt in the grid
  # x : the x-size of the element in the grid
  var columns = int(floor((window_x + grid_pad_x) / (card_x + grid_pad_x)))
  if columns < 1:
    columns = 1
  grid.columns = columns


func _card_pressed(card_outline:CardOutline, card_id:int, set_rarity_code:String):
  # Find card to pull info from
  for card in Info.cards:
    if card.id == card_id:
      # Update full view card name
      $FullView/Margin/Control/Info/List/Name.text = card.name
      # Update full view card rarity
      $FullView/Margin/Control/Info/List/Rarity.text = set_rarity_code
      # Update full view card description
      $FullView/Margin/Control/Info/Desc.text = card.desc
      for card_set in card.card_sets:
        if set.set_name == card_set.set_name and card_set.set_rarity_code == set_rarity_code:
          # Update full view first edition card amount
          $FullView/Margin/Control/Info/First/Amount.text = "%d" % card_set.first_editions
          # Update full view reprint card amount
          $FullView/Margin/Control/Info/Reprint/Amount.text = "%d" % card_set.reprints
          # Update full view card id + set code
          $FullView/Margin/Control/Info/List/Id.text = "%s (%d)" % [card_set.set_code, card.id]
          # Update full view card price in set
          $FullView/Margin/Control/Info/Prices.text = "$%s" % card_set.set_price
      break
  
  # Update full view card image
  $FullView/Margin/Control/Image.texture = get_card_texture(card_id)
  
  # Update the card currently being viewed in full view
  current_card.id = card_id
  current_card.set_rarity_code = set_rarity_code
  current_card.outline = card_outline
  $FullView.show()


func _back_pressed():
  $FullView.hide()
