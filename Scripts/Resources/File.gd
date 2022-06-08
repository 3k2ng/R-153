extends Resource
class_name File

enum FileType {
	DIRECTORY,
	TEXT,
	EXECUTABLE
}

export(FileType) var file_type

export(String) var file_name: String
export(String) var location: String
export(String, MULTILINE) var content: String
