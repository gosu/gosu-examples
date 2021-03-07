class Example
  attr_accessor :caption
  attr_reader :width, :height
  attr_writer :parent_window

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

  def close
    # no-op, examples cannot close the containing window.
  end

  def mouse_x
    @parent_window && @parent_window.mouse_x
  end

  def mouse_y
    @parent_window && @parent_window.mouse_y
  end

  def text_input
    @parent_window && @parent_window.text_input
  end

  def text_input=(text_input)
    @parent_window && @parent_window.text_input = text_input
  end

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
    @@examples.keys
  end

  def self.source_file
    @@examples[self]
  end

  def self.initial_example
    @@examples.keys.find { |cls| cls.name.end_with? "::Welcome" }
  end

  def self.load_examples(pattern)
    Dir.glob(pattern) do |file|
      begin
        # Remember which file we are loading.
        Example.current_source_file = File.expand_path(file)

        # Load the example in a sandbox module (second parameter to load()). This way, examples can
        # define classes and constants with the same names, and they will not collide.
        #
        # load() does not let us refer to the anonymous module it creates, but we can enumerate all
        # loaded examples using Example.examples thanks to the "inherited" callback above.
        load file, true
      rescue Exception => e
        puts "*** Cannot load #{file}:"
        puts e
        puts
      end
    end
  end
end
