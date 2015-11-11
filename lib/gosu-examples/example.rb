class Example
  attr_accessor :caption
  attr_reader :width, :height

  def initialize(width, height, *options)
    @width, @height = width, height
  end

  def draw
  end

  def update
  end

  def button_down(id)
  end

  def button_up(id)
  end
end

class Feature < Example
  def self.inherited(subclass)
    @@features ||= {}
    @@features[subclass] = self.current_source_file
  end

  def self.features
    @@features.keys
  end

  def self.source_file
    @@examples[self]
  end
end

class Example
  def self.current_source_file
    @current_source_file
  end

  def self.current_source_file=(current_source_file)
    @current_source_file = current_source_file
  end

  def self.inherited(subclass)
    @@examples ||= {}
    @@examples[subclass] = self.current_source_file
  end

  def self.examples
    @@examples.keys - [Feature]
  end

  def self.source_file
    @@examples[self]
  end

  def self.load_examples(pattern)
    Dir.glob(pattern) do |file|
      begin
        # Remember that all examples and features being loaded now must come from the
        # next file.
        #
        Example.current_source_file = File.expand_path(file)

        # Load the example/feature in a sandbox module (second parameter). This way,
        # several examples can define a Player class without colliding.
        #
        # load() does not let us refer to the anonymous module it creates, but we
        # can enumerate all loaded examples and features using Example.examples and
        # Feature.features afterwards.
        #
        load file, true
      rescue Exception => e
        puts "*** Cannot load #{file}:"
        puts e
        puts
      end
    end
  end
end
