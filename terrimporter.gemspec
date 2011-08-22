# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "terrimporter/version"

Gem::Specification.new do |s|
  s.name        = "terrimporter"
  s.version     = Terrimporter::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Daniel Kummer"]
  s.email       = ["daniel.kummer@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Import terrific javascripts, css files and images into a web project}
  s.description = %q{This gem allows terrific(http://terrifically.org/) project import of css, javascript and image files based on a command line tool and a configuration file.}

  s.rubyforge_project = "terrimporter"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "shoulda", [">= 0"]
  s.add_development_dependency "bundler", ["~> 1.0.0"]
  s.add_development_dependency "jeweler", ["~> 1.6.4"]
  s.add_development_dependency "rcov", [">= 0"]

end
