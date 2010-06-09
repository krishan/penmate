def compress(source)
  replacements = {
    "\n\n" => "\n",
    ";;" => ";",
    "\n" => ";",
    " = " => "=",
    "? " => "?",
    ", {" => ",{",
    " => " => "=>",
    ", \"" => ",\"",
    " == " => "==",
    ") { |" => "){|",
    ") }" => ")}",
    "| " => "|",
    " }" => "}",
    "file_name" => "n",
    "file_content" => "c",
    "result" => "r",
    "edited_content" => "e",
    "ARGV" => "$*",
    "handle" => "h"
  }

  replacments.each{ |search, replace| source.gsub!(search, replace) }

  source
end
