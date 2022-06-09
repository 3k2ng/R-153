extends Resource
class_name File

enum FileType {
	DIRECTORY,
	TEXT,
	EXECUTABLE
}

export(FileType) var file_type

export(String) var file_name
export(Resource) var file_owner # User that own this file, must use User

export(bool) var is_private # Can non-owner open the file

export(String) var location
export(String, MULTILINE) var content
