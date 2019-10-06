class Sidebar
  WIDTH = 300
  HEIGHT = 600
  FONT = Gosu::Font.new(20)
  HEADER = Gosu::Image.new("#{File.dirname __FILE__}/media/header@2x.psd", tileable: true)
  
  class Button
    HEIGHT = 25
    SPACING = 5
    TOP_Y = HEADER.height / 2 + 15
    
    attr_reader :filename
    
    def initialize(top, filename, &handler)
      @top, @filename, @handler = top, filename, handler
    end
    
    def draw(is_current)
      text_color = Gosu::Color::BLACK
      
      if is_current
        Gosu.draw_rect 0, @top, Sidebar::WIDTH, HEIGHT, 0xff_1565e5
        text_color = Gosu::Color::WHITE
      end
      
      FONT.draw_text File.basename(@filename), 13, @top + 2, 0, 1, 1, text_color
    end
    
    def click
      @handler.call
    end
  end
  
  def initialize
    y = Button::TOP_Y - Button::HEIGHT - Button::SPACING
    
    @buttons = Example.examples.map do |example|
      y += (Button::HEIGHT + Button::SPACING)
      
      Button.new(y, example.source_file) do
        yield(example)
      end
    end
  end
  
  def draw(current_filename)
    Gosu.draw_rect 0, 0, WIDTH, HEIGHT, Gosu::Color::WHITE
    HEADER.draw 0, 0, 0, 0.5, 0.5
    
    @buttons.each do |button|
      is_current = (button.filename == current_filename)
      button.draw(is_current)
    end
  end
  
  def click(x, y)
    index = (y - Button::TOP_Y).floor / (Button::HEIGHT + Button::SPACING)
    @buttons[index].click if @buttons[index]
  end
end
