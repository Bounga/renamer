require 'lib/const.rb'

Gem::Specification.new do |s|
    s.platform  = Gem::Platform::RUBY
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