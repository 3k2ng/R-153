extends Resource
class_name CustomFile

export(String) var file_name
export(String) var file_owner # User that own this file, use name

export(bool) var is_private # Can non-owner open the file
export(bool) var is_directory

export(String) var location
export(String, MULTILINE) var content
