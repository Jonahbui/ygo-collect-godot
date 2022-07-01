extends Node

const META = preload("res://src/meta.gd")
const META_FILE = "meta.tres"

const RSRC_PATH := "user://resources"
const CARDS_PATH := "user://resources/cards"
const SETS_PATH := "user://resources/sets"
const CARD = preload("res://src/card.gd")
const SET = preload("res://src/set.gd")

var meta : Meta
export var sets : Array
export var cards : Array

func _ready() -> void:
  # Create necessary directories for local data
  var dir = Directory.new()
  dir.open("user://")
  dir.make_dir_recursive("resources/sets")
  dir.make_dir_recursive("resources/cards")
  
  # Create meta file if it does not exists, else load it
  var meta_path = "%s/%s" % [RSRC_PATH, META_FILE]
  if not ResourceLoader.exists(meta_path):
    meta = META.new()
    ResourceSaver.save(meta_path, meta, ResourceSaver.FLAG_CHANGE_PATH)
  else:
    meta = ResourceLoader.load(meta_path, "Resource", true)


func _exit_tree():
  save_meta()


func get_set_by_name(set_name:String):
  for set in sets:
    if set.set_name == set_name:
      return set
  return null

func generate_resources(card_sets_path:String, card_info_path:String) -> int:
  if Bitmask.is_flag_set(Info.meta.mask, Meta.SET_RESOURCES_NEED_UPDATE):
    var parse = Parse.read_json(card_sets_path)
    if not parse:
      return ERR_FILE_CANT_READ
    
    # Generate set resources
    var card_sets = parse.result
    card_sets.sort_custom(Main, "sort_by_date_desc")
    
    for set in card_sets:
      var set_name = set.set_name
      set_name = clean(set_name)
      var set_path = "%s/%s.tres" % [SETS_PATH, set_name]
      
      # Load a set, but update its info
      if ResourceLoader.exists(set_path):
        # TODO: update set info
        # NOTE: meta should contain the set
        var loaded_set : Set = ResourceLoader.load(set_path, "Resource", true)
        loaded_set.set_name = set.set_name
        loaded_set.set_code = set.set_code
        loaded_set.num_of_cards = set.num_of_cards
        if set.has("tcg_date"):
          loaded_set.tcg_date = set.tcg_date
        Info.sets.append(loaded_set)
      # Generate a new set
      else:
        # Restore checkpoint
        if not Info.meta.last_set_created.empty():
          if Info.meta.last_set_created != set.set_name:
            continue
          else:
            Info.meta.last_set_created = ""
          
        # Create set resource
        var new_set : Set = SET.new()
        new_set.set_name = set.set_name
        new_set.set_code = set.set_code
        new_set.num_of_cards = set.num_of_cards
        if set.has("tcg_date"):
          new_set.tcg_date = set.tcg_date
        Info.sets.append(new_set)
        ResourceSaver.save(set_path, new_set, ResourceSaver.FLAG_CHANGE_PATH)
        Info.meta.last_set_created = set.set_name
        save_meta()
    # TODO: create a default "unknown" set
    
    Info.meta.mask = Bitmask.set_flag(Info.meta.mask, Meta.SET_RESOURCES_NEED_UPDATE, false)
    Info.meta.last_set_created = ""
    save_meta()
  else:
    print("Loading set resources from local.")
    for set_path in get_files_in_dir(SETS_PATH, true):
      Info.sets.append(ResourceLoader.load(set_path, "Resource", true))
  
  # Generate card resources
  if Bitmask.is_flag_set(Info.meta.mask, Meta.CARD_RESOURCES_NEED_UPDATE):
    var parse = Parse.read_json(card_info_path)
    if not parse:
      return ERR_FILE_CANT_READ
    var card_info = parse.result.data
    for card in card_info:
      var card_path = "%s/%s.tres" % [CARDS_PATH, card.id]
      
      # Load an existing card, but update its info
      if ResourceLoader.exists(card_path):
        # TODO: update card info
        var loaded_card : Card = ResourceLoader.load(card_path , "Resource", true)
        loaded_card.id = card.id
        loaded_card.name = card.name
        loaded_card.type = card.type
        loaded_card.race = card.race
        if card.has("desc"):
          loaded_card.desc = card.desc
        if card.has("archetype"):
          loaded_card.archetype = card.archetype
        if card.has("card_sets"):
          # TODO: figure out how to update card_sets
          # 1. What if a new card set appears
          # 2. What if a card set has its name updated. What to do about its cards
          for card_set in card.card_sets:
            pass
        Info.cards.append(loaded_card)

      # Generate a new card
      else:
        # Restore checkpoint
        if Info.meta.last_card_created != -1:
          if Info.meta.last_card_created != card.id:
            continue
          else:
            Info.meta.last_card_created = -1
        
        # Create new card resource
        var new_card : Card = CARD.new()
        new_card.id = card.id
        new_card.name = card.name
        new_card.type = card.type
        new_card.race = card.race
        if card.has("desc"):
          new_card.desc = card.desc
        if card.has("archetype"):
          new_card.archetype = card.archetype
        if card.has("card_sets"):
          for card_set in card.card_sets:
            card_set["first_editions"] = 0
            card_set["reprints"] = 0
        else:
          card["card_sets"] = {
            "set_name": Set.DEFAULT_SET_NAME,
            "set_code": Set.DEFAULT_SET_CODE,
            "set_price": "?",
            "set_rarity": "Unknown",
            "set_rarity_code": "(?)",
          }
          new_card.card_sets = card.card_sets
        new_card.card_images = card.card_images
        if card.has("card_prices"):
          new_card.card_prices = card.card_prices
        Info.cards.append(new_card)
        ResourceSaver.save(card_path, new_card, ResourceSaver.FLAG_CHANGE_PATH)
        Info.meta.last_card_created = card.id
        save_meta()
    Info.meta.mask = Bitmask.set_flag(Info.meta.mask, Meta.CARD_RESOURCES_NEED_UPDATE, false)
    Info.meta.last_card_created = -1
    save_meta()
  else:
    print("Loading card resources from local.")
    for card_path in get_files_in_dir(CARDS_PATH, true):
      Info.cards.append(ResourceLoader.load(card_path, "Resource", true))

  return OK


func save_meta() -> void:
  var meta_path = "%s/%s" % [RSRC_PATH, META_FILE]
  ResourceSaver.save(meta_path, meta, ResourceSaver.FLAG_CHANGE_PATH)


# : / \ ? * " | % < >
static func clean(filename:String) -> String:
  return filename.replace(':','').replace('/', '').replace('\\', '').replace('?', '') \
  .replace('*', '').replace('\"', '').replace('|', '').replace('%%', '').replace('<', '')
  .replace('>', '').replace(' ', ''). replace('-', '')


static func get_files_in_dir(dir_path:String, full_path:bool=true) -> Array:
  var files := []
  var dir = Directory.new()
  if dir.open(dir_path) != OK:
    print("An error occurred when trying to access the path.")
    
  dir.list_dir_begin()
  var filename = dir.get_next()
  while filename != "":
      if not dir.current_is_dir():
          files.append(filename if not full_path else "%s/%s" % [dir_path, filename])
      filename = dir.get_next()
  return files


static func sort_set_by_date(a:Set,b:Set) -> bool:
  if not a.has('tcg_date'):
    return true
  if not b.has('tcg_date'):
    return false
  return a.tcg_date < b.tcg_date


static func sort_set_by_date_desc(a:Set, b:Set) -> bool:
  return a.tcg_date > b.tcg_date
