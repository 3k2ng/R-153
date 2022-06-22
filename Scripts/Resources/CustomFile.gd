extends Resource
class_name CustomFile

enum FileType {
	DIRECTORY,
	TEXT,
	EXECUTABLE
}

export(FileType) var file_type: int

export(String) var file_name: String
export(String) var file_owner # User that own this file, use name

export(bool) var is_private # Can non-owner open the file

export(String) var location
export(String, MULTILINE) var content
