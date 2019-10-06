Gem::Specification.new do |s|
  s.name        = "gosu-examples"
  s.version     = "1.0.5"
  s.author      = "Julian Raschke"
  s.email       = "julian@raschke.de"
  s.homepage    = "http://www.libgosu.org/"
  s.summary     = "Ruby examples for the Gosu library"
  s.description = "The `gosu-examples` tool provides an easy way to run and " +
                  "inspect example games written for the Gosu game " +
                  "development library."
  s.executables = %w(gosu-examples)
  s.files       = %w(bin/gosu-examples LICENSE README.md) +
                  Dir.glob("{lib,examples}/**/*.rb") +
                  Dir.glob("{lib,examples}/media/**/*")

  s.add_dependency "gosu", ">= 0.14.0"
end
