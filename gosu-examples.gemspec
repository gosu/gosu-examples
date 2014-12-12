minor_version = `git rev-list master`.split.size

Gem::Specification.new do |s|
  s.name        = "gosu-examples"
  s.version     = "0.0.#{minor_version}"
  s.author      = "Julian Raschke"
  s.email       = "julian@raschke.de"
  s.homepage    = "http://www.libgosu.org/"
  s.required_ruby_version = Gem::Requirement.new('>= 1.8.2')
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Ruby examples for the Gosu library"
  s.description = "The `gosu-examples` tool provides an easy way to run and " +
                  "inspect example games written for the Gosu game development " +
                  "library."
  
  s.add_dependency "gosu"
  
  s.files        = %w(bin/gosu-examples LICENSE README.md) + Dir.glob("**/*.rb") + Dir.glob("examples/media/**/*")
  s.executables  = ['gosu-examples']
end
