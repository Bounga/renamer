class Renamer
  # Process command-line arguments
  class CommandLine
    attr_accessor :action, :arg, :recursive, :overwrite, :opts, :filenames
    
    def initialize
      $VERBOSE, self.recursive, self.overwrite = false
      self.action, self.arg = nil
      
      feed
      parse
      process
    end
    
    private
    
    # Define available options
    def feed
      opts = OptionParser.new
      
      opts.banner = _("Usage: %s [options] FILENAMES") % File.basename($0)
      opts.separator ""
      opts.separator _("Specific options:")

      opts.on("-d", "--downcase", _("Downcase FILENAMES")) { self.action = :downcase }
      opts.on("-u", "--upcase", _("Upcase FILENAMES")) { self.action = :upcase }
      opts.on("-c", "--capitalize", _("Capitalize FILENAMES")) { self.action = :capitalize }
      opts.on("-w", "--word", _("Capitalize each words in FILENAMES")) { self.action = :word }
      opts.on("--downcase_ext", _("Downcase FILENAMES extensions")) { self.action = :downcase_ext }
      opts.on("--upcase_ext", _("Upcase FILENAMES extensions")) { self.action = :upcase_ext }
      opts.on("-s", "--space", _("Replace spaces by underscores in FILENAMES")) { self.action = :space }
      opts.on("-U", "--underscore", _("Replace underscores by spaces in FILENAMES")) { self.action = :underscore }
      opts.on("--date", _("Add current date to the beginning of FILENAMES")) { self.action = :date }
      opts.on("--datetime", _("Add current datetime to the beginning of FILENAMES")) { self.action = :datetime }
      opts.on("-b", _("--basename BASENAME"), _("Rename FILENAMES using the specified"), _("BASENAME followed by an incremental number")) { |bn| self.action = :basename; self.arg = bn }
      opts.on("-e", _("--ext NEW"), _("Rename FILENAMES from their actual extension"), _("to the NEW one")) { |new| self.action = :ext; self.arg = new }
      opts.on("-f", "--trim-first n", _("Rename FILENAMES by trimming first n characters")) { |n| self.action = :trim_first; self.arg = n }
      opts.on("-l", "--trim-last n", _("Rename FILENAMES by trimming last n characters")) { |n| self.action = :trim_last; self.arg = n }
      opts.on("-r", "--recursive", _("Run %s recursively across directories") % Const::NAME) { self.recursive = true }
      opts.on("-o", "--overwrite", _("Overwrite existing files if needed") % Const::NAME) { self.overwrite = true }

      opts.separator ""
      opts.separator _("Common options:")

      opts.on_tail("-h", "--help", _("Show this help")) { puts opts.to_s; exit(0) }
      opts.on("-v", "--version", _("Show %s version") % Const::NAME) { puts Const::NAME + " v" + Const::VER; exit(0) }
      opts.on("-L", "--license", _("Show some information about %s license") % Const::NAME) { puts Const::LICENSE; exit(0) }
      opts.on("-V", "--verbose", _("Run %s in verbose mode (quiet by default)") % Const::NAME) { $VERBOSE = true }
      
      self.opts = opts
    end
    
    # Parse arguments
    def parse
      if ARGV.empty?
          puts self.opts.to_s
          exit(1)
      end
      
      self.filenames = self.opts.parse(ARGV)
    end
    
    # Send the requested job to Renamer
    def process
      r = Renamer.new(self.filenames, self.recursive, self.overwrite)

      case self.action
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
        r.basename(self.arg)
      when :ext
        r.ext(self.arg)
      when :trim_first
        r.trim_first(self.arg)
      when :trim_last
        r.trim_last(self.arg)
      when :date
        r.current_date(Time.now)
      when :datetime
        r.current_datetime(Time.now)
      end
    end
  end
end