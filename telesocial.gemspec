# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "telesocial/version"

Gem::Specification.new do |s|
  s.name        = "telesocial"
  s.version     = Telesocial::VERSION
  s.authors     = ["Selem Delul"]
  s.email       = ["selem@selem.im"]
  s.homepage    = ""
  s.summary     = %q{Ruby wrapper for Telesocial API}
  s.description = %q{Ruby wrapper for Telesocial API}

  s.rubyforge_project = "telesocial"

  s.add_development_dependency "fakeweb"
  s.add_development_dependency "rake"
  s.add_development_dependency "redgreen"
  s.add_development_dependency "rocco"
  s.add_development_dependency "rr"

  s.add_dependency "httparty"
  s.add_dependency "hashie"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
