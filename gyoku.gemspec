$:.push File.expand_path("../lib", __FILE__)
require "gyoku/version"

Gem::Specification.new do |s|
  s.name        = "gyoku"
  s.version     = Gyoku::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = "Daniel Harrington"
  s.email       = "me@rubiii.com"
  s.homepage    = "http://github.com/rubiii/#{s.name}"
  s.summary     = %q{Converts Ruby Hashes to XML}
  s.description = %q{Gyoku converts Ruby Hashes to XML}

  s.rubyforge_project = "gyoku"

  s.add_dependency "builder", ">= 2.1.2"

  s.add_development_dependency "rake",  "~> 0.9"
  s.add_development_dependency "rspec", "~> 2.10"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
