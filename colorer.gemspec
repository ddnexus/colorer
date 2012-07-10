require 'date'

Gem::Specification.new do |s|
  s.name                      = 'colorer'
  s.authors                   = ["Domizio Demichelis"]
  s.email                     = 'dd.nexus@gmail.com'
  s.homepage                  = 'http://github.com/ddnexus/colorer'
  s.summary                   = 'Easy ANSI code coloring for strings in applications'
  s.description               = 'Colorer adds the basic ANSI styles to any string, allowing also to define your own stiles'
  s.extra_rdoc_files          = ["README.rdoc"]
  s.require_paths             = ["lib"]
  s.files                     = `git ls-files -z`.split("\0")
  s.version                   = File.read(File.expand_path('../VERSION', __FILE__)).strip
  s.date                      = Date.today.to_s
  s.required_rubygems_version = ">= 1.3.6"
  s.rdoc_options              = ["--charset=UTF-8"]
  s.add_development_dependency('irt', [">= 1.1.2"])
end

