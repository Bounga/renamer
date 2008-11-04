#!/usr/bin/ruby -w
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

# Testing procs
class TestRenamerProcs < Test::Unit::TestCase
  def setup
    $VERBOSE = nil
    @files = Array.new
    Dir.mkdir("tmp_files")
    Dir.chdir("tmp_files")
  end

  def teardown  
    Dir.chdir("..")
    FileUtils.rm_rf("tmp_files")
  end

  def test_mv
    @files << File.new("PLOP", "w").path
    @files << File.new("TesT.Hop", "w").path

    r = Renamer.new(@files)
    r.downcase

    assert(!File.exist?("PLOP"))
    assert(!File.exist?("TesT.Hop"))
  end

  def test_subdirectory
    Dir.mkdir("test1")
    Dir.mkdir("test2")
    @files << File.new("test1/PLOP.txt", "w").path
    @files << File.new("test2/PLOP.txt", "w").path

    r = Renamer.new(@files)
    r.downcase

    assert(File.exist?("test1/plop.txt"))
    assert(File.exist?("test2/plop.txt"))
  end

  def test_recursivity
    Dir.mkdir("test1")
    Dir.mkdir("test1/test3")
    Dir.mkdir("test1/test3/test4")
    Dir.mkdir("test2")
    @files << File.new("test1/PLOP.txt", "w").path
    @files << File.new("test1/test3/PLOP.txt", "w").path
    @files << File.new("test1/test3/test4/PLOP.txt", "w").path
    @files << File.new("test2/PLOP.txt", "w").path

    r = Renamer.new(@files, true)
    r.downcase

    assert(File.exist?("test1/plop.txt"))
    assert(File.exist?("test1/test3/plop.txt"))
    assert(File.exist?("test1/test3/test4/plop.txt"))
    assert(File.exist?("test2/plop.txt"))
  end

  def test_overwrite
    # First we test that it doesn't overwrite when overwrite is false
    @files << File.new("plop_plop", "w").path
    @files << File.new("plop plop", "w").path

    r = Renamer.new(@files, false, false)
    r.underscore_to_space

    assert(File.exist?("plop_plop"))
    assert(File.exist?("plop plop"))

    # Now we test that files are overwrited when overwrite is true
    @files.clear
    @files << File.new("test_test", "w").path
    @files << File.new("test test", "w").path

    r = Renamer.new(@files, false, true)
    r.underscore_to_space

    assert(!File.exist?("test_test"))
    assert(File.exist?("test test"))
  end

  def test_downcase
    @files << File.new("PLOP", "w").path
    @files << File.new("PLOP.txt", "w").path
    @files << File.new("PLOP.JPG", "w").path
    @files << File.new("TesT.Hop", "w").path
    @files << File.new("test.txt", "w").path
    @files << File.new("teST.jpg.txt", "w").path

    r = Renamer.new(@files)
    r.downcase

    assert(File.exist?("plop"))
    assert(File.exist?("plop.txt"))
    assert(File.exist?("plop.jpg"))
    assert(File.exist?("test.hop"))
    assert(File.exist?("test.txt"))
    assert(File.exist?("test.jpg.txt"))
  end

  def test_upcase
    @files << File.new("plop", "w").path
    @files << File.new("PLOP.txt", "w").path
    @files << File.new("PLOP.JPG", "w").path
    @files << File.new("TesT.Hop", "w").path
    @files << File.new("test.txt", "w").path
    @files << File.new("teST.jpg.txt", "w").path

    r = Renamer.new(@files)
    r.upcase

    assert(File.exist?("PLOP"))
    assert(File.exist?("PLOP.TXT"))
    assert(File.exist?("PLOP.JPG"))
    assert(File.exist?("TEST.HOP"))
    assert(File.exist?("TEST.TXT"))
    assert(File.exist?("TEST.JPG.TXT"))
  end

  def test_space_to_underscore
    @files << File.new("plop plop", "w").path
    @files << File.new("PLOP.txt", "w").path
    @files << File.new("PLOP PLOP PLOP.avi", "w").path
    @files << File.new("TesT .Hop", "w").path
    @files << File.new("test. txt", "w").path
    @files << File.new("teST.jpg.txt", "w").path

    r = Renamer.new(@files)
    r.space_to_underscore

    assert(File.exist?("plop_plop"))
    assert(File.exist?("PLOP.txt"))
    assert(File.exist?("PLOP_PLOP_PLOP.avi"))
    assert(File.exist?("TesT_.Hop"))
    assert(File.exist?("test._txt"))
    assert(File.exist?("teST.jpg.txt"))
  end

  def test_underscore_to_space
    @files << File.new("plop_plop", "w").path
    @files << File.new("PLOP.txt", "w").path
    @files << File.new("PLOP_PLOP_PLOP.avi", "w").path
    @files << File.new("TesT_.Hop", "w").path
    @files << File.new("test._txt", "w").path
    @files << File.new("teST.jpg.txt", "w").path

    r = Renamer.new(@files)
    r.underscore_to_space

    assert(File.exist?("plop plop"))
    assert(File.exist?("PLOP.txt"))
    assert(File.exist?("PLOP PLOP PLOP.avi"))
    assert(File.exist?("TesT .Hop"))
    assert(File.exist?("test. txt"))
    assert(File.exist?("teST.jpg.txt"))
  end

  def test_capitalize
    @files << File.new("plop_plop", "w").path
    @files << File.new("PLOP.txt", "w").path
    @files << File.new("Plop.avi", "w").path
    @files << File.new("TesT_.Hop", "w").path
    @files << File.new("test test.TXT", "w").path
    @files << File.new("teST.jpg.txt", "w").path

    r = Renamer.new(@files)
    r.capitalize

    assert(File.exist?("Plop_plop"))
    assert(File.exist?("Plop.txt"))
    assert(File.exist?("Plop.avi"))
    assert(File.exist?("Test_.hop"))
    assert(File.exist?("Test test.txt"))
    assert(File.exist?("Test.jpg.txt"))
  end

  def test_capitalize_words
    @files << File.new("plop_plop", "w").path
    @files << File.new("PLOP.txt", "w").path
    @files << File.new("Plop.avi", "w").path
    @files << File.new("TesT_.Hop", "w").path
    @files << File.new("test test.txt", "w").path
    @files << File.new("test test_test.txt", "w").path
    @files << File.new("teST.jpg.txt", "w").path
    @files << File.new(".dotfile", "w").path

    r = Renamer.new(@files)
    r.capitalize_words

    assert(File.exist?("Plop_Plop"))
    assert(File.exist?("Plop.txt"))
    assert(File.exist?("Plop.avi"))
    assert(File.exist?("Test_.hop"))
    assert(File.exist?("Test Test.txt"))
    assert(File.exist?("Test Test_Test.txt"))
    assert(File.exist?("Test.Jpg.txt"))
    assert(File.exist?(".dotfile"))
  end

  def test_basename
    @files << File.new("plop_plop.txt", "w").path
    @files << File.new("PLOP.txt", "w").path
    @files << File.new("TesT_.txt", "w").path
    @files << File.new("test test.txt", "w").path
    @files << File.new("test test_test.txt", "w").path
    @files << File.new("teST.jpg.txt", "w").path
    @files << File.new("Plop", "w").path
    @files << File.new("test0004.txt", "w").path

    r = Renamer.new(@files)
    r.basename("test")

    assert(File.exist?("test0000.txt"))
    assert(File.exist?("test0001.txt"))
    assert(File.exist?("test0002.txt"))
    assert(File.exist?("test0003.txt"))
    assert(File.exist?("test0005.txt"))
    assert(File.exist?("test0006.txt"))
    assert(File.exist?("test0000"))
  end

  def test_ext
    @files << File.new("plop_plop", "w").path
    @files << File.new("PLOP.txt", "w").path
    @files << File.new("Plop.avi", "w").path
    @files << File.new("TesT_.Hop", "w").path
    @files << File.new("test test.txt", "w").path
    @files << File.new("test test_test.txt", "w").path
    @files << File.new("teST.jpg.txt", "w").path
    @files << File.new(".dotfile", "w").path
    Dir.mkdir("tmp_files2")
    @files << File.new("tmp_files2/.dotfile", "w").path

    r = Renamer.new(@files)
    r.ext("rnm")

    assert(File.exist?("plop_plop.rnm"))
    assert(File.exist?("PLOP.rnm"))
    assert(File.exist?("Plop.rnm"))
    assert(File.exist?("TesT_.rnm"))
    assert(File.exist?("test test.rnm"))
    assert(File.exist?("test test_test.rnm"))
    assert(File.exist?("teST.jpg.rnm"))
    assert(File.exist?(".dotfile"))
    assert(File.exist?("tmp_files2/.dotfile"))
  end

  def test_downcase_ext
    @files << File.new("plop_plop", "w").path
    @files << File.new("PLOP.txt", "w").path
    @files << File.new("Plop.AvI", "w").path
    @files << File.new("TesT_.Hop", "w").path
    @files << File.new("test test.TXT", "w").path
    @files << File.new("test test_test.TXT", "w").path
    @files << File.new("teST.jpg.TXT", "w").path
    @files << File.new(".DotFile", "w").path
    Dir.mkdir("tmp_files2")
    @files << File.new("tmp_files2/.DotFile", "w").path

    r = Renamer.new(@files)
    r.downcase_ext

    assert(File.exist?("plop_plop"))
    assert(File.exist?("PLOP.txt"))
    assert(File.exist?("Plop.avi"))
    assert(File.exist?("TesT_.hop"))
    assert(File.exist?("test test.txt"))
    assert(File.exist?("test test_test.txt"))
    assert(File.exist?("teST.jpg.txt"))
    assert(File.exist?(".DotFile"))
    assert(File.exist?("tmp_files2/.DotFile"))
  end

  def test_upcase_ext
    @files << File.new("plop_plop", "w").path
    @files << File.new("PLOP.txt", "w").path
    @files << File.new("Plop.AvI", "w").path
    @files << File.new("TesT_.Hop", "w").path
    @files << File.new("test test.TXT", "w").path
    @files << File.new("test test_test.TXT", "w").path
    @files << File.new("teST.jpg.TXT", "w").path
    @files << File.new(".DotFile", "w").path
    Dir.mkdir("tmp_files2")
    @files << File.new("tmp_files2/.DotFile", "w").path

    r = Renamer.new(@files)
    r.upcase_ext

    assert(File.exist?("plop_plop"))
    assert(File.exist?("PLOP.TXT"))
    assert(File.exist?("Plop.AVI"))
    assert(File.exist?("TesT_.HOP"))
    assert(File.exist?("test test.TXT"))
    assert(File.exist?("test test_test.TXT"))
    assert(File.exist?("teST.jpg.TXT"))
    assert(File.exist?(".DotFile"))
    assert(File.exist?("tmp_files2/.DotFile"))
  end

  def test_trim_first_characters
    @files << File.new("plop_plop", "w").path
    @files << File.new("abracadabra.txt", "w").path
    @files << File.new("abcdefij.klm.txt", "w").path

    r = Renamer.new(@files)
    r.trim_first(5)

    assert(File.exist?("plop"))
    assert(File.exist?("adabra.txt"))
    assert(File.exist?("fij.klm.txt"))
  end

  def test_trim_last_characters
    @files << File.new("plop_plouf", "w").path
    @files << File.new("abracadabra.txt", "w").path
    @files << File.new("abcdefij.klm.txt", "w").path

    r = Renamer.new(@files)
    r.trim_last(4)

    assert(File.exist?("plop_p"))
    assert(File.exist?("abracad.txt"))
    assert(File.exist?("abcdefij.txt"))
  end

  def test_date
    @files << File.new("plop_plouf", "w").path
    @files << File.new("abracadabra.txt", "w").path

    time = Time.now

    r = Renamer.new(@files)
    r.current_date(time)

    assert(File.exist?([time.strftime("%Y-%m-%d"), "plop_plouf"].join('_')))
    assert(File.exist?([time.strftime("%Y-%m-%d"), "abracadabra.txt"].join('_')))
  end

  def test_datetime
    @files << File.new("plop_plouf", "w").path
    @files << File.new("abracadabra.txt", "w").path

    time = Time.now

    r = Renamer.new(@files)
    r.current_datetime(time)

    assert(File.exist?([time.strftime("%Y-%m-%d_%H-%M"), "plop_plouf"].join('_')))
    assert(File.exist?([time.strftime("%Y-%m-%d_%H-%M"), "abracadabra.txt"].join('_')))
  end
end