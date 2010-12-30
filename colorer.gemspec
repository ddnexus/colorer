name = File.basename( __FILE__, '.gemspec' )
version = File.read(File.expand_path('../VERSION', __FILE__)).strip
require 'date'

Gem::Specification.new do |s|

  s.authors = ["Domizio Demichelis"]
  s.email = 'dd.nexus@gmail.com'
  s.homepage = 'http://github.com/ddnexus/colorer'
  s.summary = 'Easy ANSI code coloring for strings'
  s.description = 'Colorer adds the basic ANSI styles to any string, allowing also to define your own stiles'

  s.add_development_dependency('irt', [">= 1.0.0"])

  s.files = `git ls-files -z`.split("\0")

  s.name = name
  s.version = version
  s.date = Date.today.to_s

  s.required_rubygems_version = ">= 1.3.6"
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]

end

