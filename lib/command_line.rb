class Renamer
  module CommandLine
    def self.feed
      opts = OptionParser.new
      
      opts.banner = _("Usage: %s [options] FILENAMES") % File.basename($0)
      opts.separator ""
      opts.separator _("Specific options:")

      opts.on("-d", "--downcase", _("Downcase FILENAMES")) { action = :downcase }
      opts.on("-u", "--upcase", _("Upcase FILENAMES")) { action = :upcase }
      opts.on("-c", "--capitalize", _("Capitalize FILENAMES")) { action = :capitalize }
      opts.on("-w", "--word", _("Capitalize each words in FILENAMES")) { action = :word }
      opts.on("--downcase_ext", _("Downcase FILENAMES extensions")) { action = :downcase_ext }
      opts.on("--upcase_ext", _("Upcase FILENAMES extensions")) { action = :upcase_ext }
      opts.on("-s", "--space", _("Replace spaces by underscores in FILENAMES")) { action = :space }
      opts.on("-U", "--underscore", _("Replace underscores by spaces in FILENAMES")) { action = :underscore }
      opts.on("--date", _("Add current date to the beginning of FILENAMES")) { action = :date }
      opts.on("--datetime", _("Add current datetime to the beginning of FILENAMES")) { action = :datetime }
      opts.on("-b", _("--basename BASENAME"), _("Rename FILENAMES using the specified"), _("BASENAME followed by an incremental number")) { |bn| action = :basename; arg = bn }
      opts.on("-e", _("--ext NEW"), _("Rename FILENAMES from their actual extension"), _("to the NEW one")) { |new| action = :ext; arg = new }
      opts.on("-f", "--trim-first n", _("Rename FILENAMES by trimming first n characters")) { |n| action = :trim_first; arg = n }
      opts.on("-l", "--trim-last n", _("Rename FILENAMES by trimming last n characters")) { |n| action = :trim_last; arg = n }
      opts.on("-r", "--recursive", _("Run %s recursively across directories") % Const::NAME) { recursive = true }
      opts.on("-o", "--overwrite", _("Overwrite existing files if needed") % Const::NAME) { overwrite = true }

      opts.separator ""
      opts.separator _("Common options:")

      opts.on_tail("-h", "--help", _("Show this help")) { puts opts.to_s; exit(0) }
      opts.on("-v", "--version", _("Show %s version") % Const::NAME) { puts Const::NAME + " v" + Const::VER; exit(0) }
      opts.on("-L", "--license", _("Show some information about %s license") % Const::NAME) { puts Const::LICENSE; exit(0) }
      opts.on("-V", "--verbose", _("Run %s in verbose mode (quiet by default)") % Const::NAME) { $VERBOSE = true }
      
      return opts
    end
    
    def self.parse(opts)
      if ARGV.empty?
          puts opts.to_s
          exit(1)
      end
      
      opts.parse(ARGV)
    end
    
    def self.process(action, arg, filenames, recursive, overwrite)
      r = Renamer.new(filenames, recursive, overwrite)

      case action
      when :downcase
        r.downcase
      when :upcase
        r.upcase
      when :downcase_ext
        r.downcase_ext
      when :upcase_ext
        r.upcase_ext
      when :capitalize
        r.capitalize
      when :word
        r.capitalize_words
      when :space
        r.space_to_underscore
      when :underscore
        r.underscore_to_space
      when :basename
        r.basename(arg)
      when :ext
        r.ext(arg)
      when :trim_first
        r.trim_first(arg)
      when :trim_last
        r.trim_last(arg)
      when :date
        r.current_date(Time.now)
      when :datetime
        r.current_datetime(Time.now)
      end
    end
  end
end