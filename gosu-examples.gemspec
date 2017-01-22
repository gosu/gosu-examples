Gem::Specification.new do |s|
  s.name        = "gosu-examples"
  s.version     = "1.0.4"
  s.author      = "Julian Raschke"
  s.email       = "julian@raschke.de"
  s.homepage    = "http://www.libgosu.org/"
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.2")
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Ruby examples for the Gosu library"
  s.description = "The `gosu-examples` tool provides an easy way to run and " +
                  "inspect example games written for the Gosu game development " +
                  "library."
  
  s.add_dependency "gosu", ">= 0.11.0"
  
  s.files        = %w(bin/gosu-examples LICENSE README.md) + Dir.glob("{lib,examples}/**/*.rb") + Dir.glob("examples/media/**/*")
  s.executables  = %w(gosu-examples)
end
