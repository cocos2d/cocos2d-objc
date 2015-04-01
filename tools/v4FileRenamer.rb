# CONFIGURATION
# Edit this part of the script to configure it to your needs.

def rename_file(from, to)
	system_echo "git mv '#{from}' '#{to}'"
end

def delete_file(file)
	system_echo "git rm '#{file}'"
end

# Ignore these suffixes
SUFFIX_BLACKLIST = [
	"-ipad",
]

# Ignore these directories
DIRECTORY_BLACKLIST = [
	"resources-tablet",
]

# END CONFIGURATION

root = (ARGV[0] or Dir.pwd)

puts "Working in #{root}"
puts

Dir.chdir(root)

def system_echo(cmd)
	puts cmd
	system cmd
end

def explode_name(file)
	ext = File.extname(file)
	base = File.basename(file, ext)
	
	# Handle multiple extentions (ex: .pvr.ccz)
	until File.extname(base).empty?
		ext = File.extname(base) + ext
		base = File.basename(file, ext)
	end
	
	dir = File.dirname(file)
	
	return dir, base, ext
end

SUFFIXES = {
	"-hd" => "-2x",
	"-ipad" => "-2x",
	"-ipadhd" => "-4x",
}

def find_suffix(base)
	for suffix, tag in SUFFIXES do
		return suffix if base.end_with? suffix
	end
	
	return nil
end

DIRECTORIES = {
	"resources-phone" => "-1x",
	"resources-phonehd" => "-2x",
	"resources-tablet" => "-2x",
	"resources-tablethd" => "-4x",
}

def find_directory(dir)
	for directory, tag in DIRECTORIES do
		return directory if dir.end_with? directory
	end
	
	return nil
end

def cleanup_and_guess_tag(file)
	dir, base, ext = explode_name(file)
	
	suffix = find_suffix(base)
	if suffix
		base = base[0...-suffix.length]
		return "#{dir}/#{base}#{ext}", SUFFIXES[suffix]
	end
	
	directory = find_directory(dir)
	if directory
		dir = File.dirname(dir)
		return "#{dir}/#{base}#{ext}", DIRECTORIES[directory]
	end
	
	return file, nil
end

def build_name(dir, base, ext, tag)
	return "#{dir}/#{base}#{tag}#{ext}"
end

def skip(file)
	puts "Skipping '#{file}'."
end

def rename_interactive(file)
	cleaned, tag_guess = cleanup_and_guess_tag(file)
	dir, base, ext = explode_name(cleaned)
	
	guess = build_name(dir, base, ext, tag_guess)
	x0 = build_name(dir, base, ext, nil)
	x1 = build_name(dir, base, ext, "-1x")
	x2 = build_name(dir, base, ext, "-2x")
	x4 = build_name(dir, base, ext, "-4x")
	
	return_skip = (file == guess)
	
	puts
	puts "File: #{file}"
	
	if return_skip
		puts "Return) Skip"
	else
		puts "Return) Rename to '#{guess}'"
	end
	
	puts "0) Rename to '#{x0}'"
	puts "1) Rename to '#{x1}'"
	puts "2) Rename to '#{x2}'"
	puts "4) Rename to '#{x4}'"
	puts "d) Delete"
	puts "s) Skip"
	
	print "Choose:"
	case STDIN.gets.chomp
	when "0"; rename_file(file, x0)
	when "1"; rename_file(file, x1)
	when "2"; rename_file(file, x2)
	when "4"; rename_file(file, x4)
	when "d"; delete_file(file)
	when "s"; skip(file)
	when ""
		if return_skip
			skip(file)
		else
			rename_file(file, guess)
		end
	else
		puts "Unknown choice."
		rename_interactive(file)
	end
end

EXT_WHITELIST = [
	".png",
	".jpg",
	".jpeg",
	".bmp",
	".tiff",
	".pvr",
	".pvr.gz",
	".pvr.ccz",
	".plist",
	".fnt",
	".tmx",
]

FILE_BLACKLIST = [
	"configCocos2d.plist",
	"fileLookup.plist",
	"spriteFrameFileList.plist",
]

class String
	def end_with_any?(arr)
		for suffix in arr do
			return true if self.end_with? suffix
		end
		
		return false
	end
end

TAGS = [
	"-1x",
	"-2x",
	"-4x",
]

IO.readlines("| find .").each do|file|
	file.chomp!
	
	dir, base, ext = explode_name(file)
	
	if(
		not EXT_WHITELIST.include? ext or
		FILE_BLACKLIST.include? File.basename(file) or
		dir.end_with_any? DIRECTORY_BLACKLIST or base.end_with_any? SUFFIX_BLACKLIST or
		base.end_with_any? TAGS
	) then
		skip(file)
		next
	end
	
	rename_interactive(file)
end
