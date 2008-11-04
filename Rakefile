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

require 'gettext/utils'
require 'rake/rdoctask'
require 'rake/testtask'
require 'rake/gempackagetask'
require 'gettext/rmsgfmt'
require 'lib/const.rb'

# Default task
desc "Create the gem and install it"
task :default => [:install]

# Gem spec
SPEC = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name      = Const::NAME
  s.version   = Const::VER
  s.author    = 'Nicolas Cavigneaux'
  s.email     = 'nico@bounga.org'
  s.homepage  = 'http://www.bitbucket.org/Bounga/renamer/'
  s.summary   = 'A fast and light utility to massively rename your files'
  s.description = 'Renamer is a tool that makes it easy to rename any number of files on any filesystem without knowing anything about shell scripting or regular expressions (regexp).'
  s.files  = Dir.glob("{bin,doc,lib,po,locale,test}/**/*")
  s.executables           = ['renamer']
  s.test_file             = 'test/ts_renamer.rb'
  s.has_rdoc              = true
  s.extra_rdoc_files      = ['README.rdoc', 'doc/FAQ.rdoc', 'doc/renamer.rdoc', 'doc/HACKING.rdoc', 'doc/TODO.rdoc', 'doc/AUTHORS.rdoc', 'doc/BUGS.rdoc', 'doc/ChangeLog.rdoc']
  s.rdoc_options          = ['--title', 'Renamer - The perfect tool to easily rename your files', '--main', 'README.rdoc', '--line-numbers']
  s.required_ruby_version = '>= 1.8.1'
  s.add_dependency('gettext')
  s.rubyforge_project = 'renamer'
end

task :gem => [:create_mo]
Rake::GemPackageTask.new(SPEC) do |pkg|
  pkg.need_zip = true
  pkg.need_tar_bz2 = true
end

desc "Generate and install the gem"
task :install => [:gem] do
  sh "gem install pkg/#{SPEC.name}-#{SPEC.version}.gem"
end

Rake::RDocTask.new do |rd|
  rd.main = "README"
  rd.rdoc_files.include('README.rdoc', 'doc/FAQ.rdoc', 'doc/renamer.rdoc', 'doc/HACKING.rdoc', 'doc/TODO.rdoc', 'doc/AUTHORS.rdoc', 'doc/BUGS.rdoc', 'doc/ChangeLog', 'bin/*', 'lib/*')
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/ts*.rb']
  t.verbose = true
end

desc "Generate MO files from PO files"
task :create_mo do
  GetText.create_mofiles(true, "po", "locale")
end

desc "Update PO files"
task :update_po do
  GetText.update_pofiles("renamer", ['bin/renamer', 'lib/const.rb', 'lib/renamer.rb'], SPEC.version)
end

desc "Remove generated MO files"
task :clobber_mo do
  sh "rm -r locale"
end

desc "Remove any generated file"
task :clobber => [:clobber_package, :clobber_rdoc, :clobber_mo] do
end