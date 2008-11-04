=begin
  Copyright (c) 2004-2008 by Nicolas Cavigneaux <nico@bounga.org>
  See COPYING for License detail.

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
=end

########################
# Initiliazing GetText #
########################
include GetText
# Searching the path to locale directory
p = File.join(File.dirname(__FILE__), "/../locale/")
bindtextdomain("renamer", p)

# Class Renamer handles files renaming
class Renamer
  EXISTS = _("%s: %s file already exists!")

  # Create a new Renamer object
  def initialize(filenames, recursive = false, overwrite = false)
    # Whether user wants to overwrite existing files or not
    @overwrite = overwrite

    # User wants to process files recursively
    if recursive
      @filenames = Array.new
      filenames.each do |f|
        if File.directory?(f)
          @filenames << Dir.glob("#{f}/**/*")
        else
          @filenames << f
        end
      end
      # In recursive mode we don't want to process directory names
      @filenames.flatten!
      @filenames.delete_if { |f| File.directory?(f) }
      # User just wants to process given files
    else
      @filenames = filenames
    end
  end

  # Downcase filenames
  def downcase
    proc_dc = Proc.new do |file|
      new = file.downcase
      rename_fs(file, new)
    end
    run(proc_dc)
  end

  # Upcase filenames
  def upcase
    proc_uc = Proc.new do |file|
      new = file.upcase
      rename_fs(file, new)
    end
    run(proc_uc)
  end

  # Downcase filename extensions
  def downcase_ext
    proc_dc_ext = Proc.new do |file|
      # We don't want to process dotfiles
      unless File.basename(file) =~ /^\./
        # We want to grep the last extension
        name = file.split('.')
        if name.size > 1 # Ensure that there's an extension
          # Now we downcase it
          ext =  name.last.downcase
          # Building the new name
          name = name[0...-1].join(".")
          new = name + '.' + ext
          # Renaming
          rename_fs(file, new)
        end
      end
    end
    run(proc_dc_ext)
  end

  # Upcase filename extensions
  def upcase_ext
    proc_uc_ext = Proc.new do |file|
      # We don't want to process dotfiles
      unless File.basename(file) =~ /^\./
        # We want to grep the last extension
        name = file.split('.')
        if name.size > 1 # Ensure that there's an extension
          # Now we upcase it
          ext =  name.last.upcase
          # Building the new name
          name = name[0...-1].join(".")
          new = name + '.' + ext
          # Renaming
          rename_fs(file, new)
        end
      end
    end
    run(proc_uc_ext)
  end

  # Replace spaces in filenames by underscores
  def space_to_underscore
    proc_s2u = Proc.new do |file|
      new = file.gsub(/\s/, '_')
      rename(file, new)
    end
    run(proc_s2u)
  end

  # Convert underscores to spaces
  def underscore_to_space
    proc_u2s = Proc.new do |file|
      new = file.gsub(/_/, ' ')
      rename(file, new)
    end
    run(proc_u2s)
  end

  # Capitalize filenames
  def capitalize
    proc_capitalize = Proc.new do |file|
      new = file.capitalize
      rename_fs(file, new)
    end
    run(proc_capitalize)
  end

  # Capitalize each word
  def capitalize_words
    proc_wcapitalize = Proc.new do |file|
      # We start with a clean downcase name
      new = file.downcase
      # Processing each words
      new.gsub!(/(?:^|[\s_\b\.])\w/) { |el| el.upcase }
      # extension has to be downcase
      new.gsub!(/(\.\w+$)/) { |el| el.downcase }
      # dotfiles have to be downcase
      new.downcase! if new =~ /^\..+/
      rename_fs(file, new)
    end
    run(proc_wcapitalize)
  end

  # Rename files using a basename and a four digits number
  def basename(bn)
    proc_basename = Proc.new do |file, basename|
      i = "0000"
      file =~ /.*?\.(.*)$/
      if $1 then
        while File.exist?("#{basename}#{i}.#{$1}")
          i = i.to_i + 1
          i = sprintf("%04d", i.to_i)
        end
        new = basename + i + "." + $1
      else
        while File.exist?("#{basename}#{i}")
          i = i.to_i + 1
          i = sprintf("%04d", i.to_i)
        end
        new = basename + i
      end
      rename(file, new)
    end
    run(proc_basename, bn)
  end

  # Change file extensions
  def ext(e)
    proc_ext = Proc.new do |file, extension|
      # We don't want to process dotfiles
      unless File.basename(file) =~ /^\./
        # We want to remove the last extension
        name = file.split(".")
        name = name[0...-1].join(".") if name.size > 1
        name = name.to_s
        # Adding the new extension
        new = (extension == "" ? name : name + "." + extension)
        rename(file, new)
      end
    end
    run(proc_ext, e)
  end

  # Trim first n characters
  def trim_first(n)
    proc_trim_first = Proc.new do |file, n|
      # Grabbing name and ext
      elements = file.split(".")
      if elements.size < 2
        name = elements.first
        ext = nil
      else
        name = elements[0...-1].join('.')
        ext = elements[-1, 1].first
      end

      # trimming the n first characters
      new = [name[n..-1], ext].compact.join('.')
      rename(file, new)
    end
    run(proc_trim_first, n)
  end

  # Trim last n characters
  def trim_last(n)
    proc_trim_last = Proc.new do |file, n|
      # Grabbing name and ext
      elements = file.split(".")
      if elements.size < 2
        name = elements.first
        ext = nil
      else
        name = elements[0...-1].join('.')
        ext = elements[-1, 1].first
      end

      # trimming the n last characters
      new = [name[0, name.length - n], ext].compact.join('.')
      rename(file, new)
    end
    run(proc_trim_last, n)
  end

  # Add date (using time arg) to the beginning of the filename
  def current_date(time)
    proc_current_date = Proc.new do |file, date|
      new = [date, file].join('_')
      rename(file, new)
    end
    run(proc_current_date, time.strftime("%Y-%m-%d"))
  end

  # Add datetime (using time arg) to the beginning of the filename
  def current_datetime(datetime)
    proc_current_datetime = Proc.new do |file, datetime|
      new = [datetime, file].join('_')
      rename(file, new)
    end
    run(proc_current_datetime, datetime.strftime("%Y-%m-%d_%H-%M"))
  end

  private
  # Helper to test files and run the specific job
  def run(a_proc, *others)
    @filenames.each do |file|
      if File.exist?(file) then
        if File.writable?(file) then
          a_proc.call(file, *others)
        else
          warn _("%s: You don't have write access on %s") % [Const::NAME, file]
        end
      else
        warn _("%s: File %s doesn't exists!") % [Const::NAME, file]
      end
    end
  end

  # Helper to rename files
  def rename(old, new)
    unless File.exist?(new) and @overwrite == false
      # Expanding paths to make them reliable
      old = File.expand_path(old)
      new = File.join(File.dirname(old), File.basename(new))
      # Renaming the file
      File.rename(old, new)
    else
      warn EXISTS % [Const::NAME, new]
    end
  end

  # Helper to rename files ensuring compatibily on all FS
  def rename_fs(old, new)
    unless File.exist?(new) and @overwrite == false
      # Expanding paths to make them reliable
      old = File.expand_path(old)
      new = File.join(File.dirname(old), File.basename(new))
      # Renaming the file
      tf = Tempfile.new("renamer")
      File.rename(old, tf.path)
      File.rename(tf.path, new)
      tf.close(true)
    else
      warn EXISTS % [Const::NAME, new]
    end
  end
end
