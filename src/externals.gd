class_name Externals
extends Node

const CARD_INFO_PATH = "user://externals/cardinfo.php"
const CARD_SETS_PATH = "user://externals/cardsets.php"
const CHECK_DB_VERSION_PATH = "user://externals/checkDBVer.php"
const CARD_IMAGES_PATH = "user://externals/images"

const CARD_INFO_URL = "https://db.ygoprodeck.com/api/v7/cardinfo.php"
const CARD_SETS_URL = "https://db.ygoprodeck.com/api/v7/cardsets.php"
const CHECK_DB_VERSION_URL = "https://db.ygoprodeck.com/api/v7/checkDBVer.php"
const IMAGE_DB_URL := "https://storage.googleapis.com/ygoprodeck.com/pics" 
const SMALL_IMAGE_DB_URL := "https://storage.googleapis.com/ygoprodeck.com/pics_small"


var http_request := HTTPRequest.new()

func _enter_tree() -> void:
  # Create directories to store card/set data, card image
  var dir = Directory.new()
  dir.open("user://")
  dir.make_dir("externals/images")
  dir.make_dir("externals")

  add_child(http_request)


func download_data() -> int:
  # Download db info
  var file := File.new()
  if not file.file_exists(CHECK_DB_VERSION_PATH) or Bitmask.is_flag_set(Info.meta.mask, Meta.DB_NEW):
    http_request.set_download_file(CHECK_DB_VERSION_PATH)
    http_request.request(CHECK_DB_VERSION_URL)
    
    var response = yield(http_request, "request_completed")
    if response[1] != 200:
      return ERR_CANT_ACQUIRE_RESOURCE
    
    Info.meta.mask = Bitmask.set_flag(Info.meta.mask, Meta.DB_NEW, false)
  else:
    print("checkDBVersion.php file found.")
  
  # Check if DB version is different from meta versions, if so, request updates
  var parse = Parse.read_json(CHECK_DB_VERSION_PATH)
  if not parse:
    return ERR_CANT_OPEN
  var result = parse.result[0]
  if result.database_version != Info.meta.last_db_version:
    Info.meta.mask = Bitmask.set_flag(Info.meta.mask, Meta.CARDS_NEED_DOWNLOAD, true)
    Info.meta.mask = Bitmask.set_flag(Info.meta.mask, Meta.SETS_NEED_DOWNLOAD, true)
    Info.meta.mask = Bitmask.set_flag(Info.meta.mask, Meta.CARD_RESOURCES_NEED_UPDATE, true)
    Info.meta.mask = Bitmask.set_flag(Info.meta.mask, Meta.SET_RESOURCES_NEED_UPDATE, true)
    Info.meta.mask = Bitmask.set_flag(Info.meta.mask, Meta.DB_NEW, true)
    Info.meta.last_db_version = result.database_version
    Info.save_meta()
  
  # Download card info 
  if not file.file_exists(CARD_INFO_PATH) or Bitmask.is_flag_set(Info.meta.mask, Meta.CARDS_NEED_DOWNLOAD):
    http_request.set_download_file(CARD_INFO_PATH)
    http_request.request(CARD_INFO_URL)
    
    var response = yield(http_request, "request_completed")
    if response[1] != 200:
      return ERR_CANT_ACQUIRE_RESOURCE
    
    Info.meta.mask = Bitmask.set_flag(Info.meta.mask, Meta.CARDS_NEED_DOWNLOAD, false)
    Info.save_meta()
  else:
    print("cardinfo.php file found.")
    
  # Download card sets
  if not file.file_exists(CARD_SETS_PATH) or Bitmask.is_flag_set(Info.meta.mask, Meta.SETS_NEED_DOWNLOAD):
    http_request.set_download_file(CARD_SETS_PATH)
    http_request.request(CARD_SETS_URL)
    
    var response = yield(http_request, "request_completed")
    if response[1] != 200:
      return ERR_CANT_ACQUIRE_RESOURCE
    
    Info.meta.mask = Bitmask.set_flag(Info.meta.mask, Meta.SETS_NEED_DOWNLOAD, false)
    Info.save_meta()
  else:
    print("cardsets.php file found.")
  return OK
