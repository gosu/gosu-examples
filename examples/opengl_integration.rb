# Encoding: UTF-8

# The tutorial game over a landscape rendered with OpenGL.
# Basically shows how arbitrary OpenGL calls can be put into
# the block given to Window#gl, and that Gosu Images can be
# used as textures using the gl_tex_info call.

require "gosu"
require "opengl"

OpenGL.load_lib

WIDTH, HEIGHT = 640, 480

module ZOrder
  Background, Stars, Player, UI = *0..3
end

# The only really new class here.
# Draws a scrolling, repeating texture with a randomized height map.
class GLBackground
  # Height map size
  POINTS_X = 7
  POINTS_Y = 7
  # Scrolling speed
  SCROLLS_PER_STEP = 50

  def initialize
    @image = Gosu::Image.new("media/earth.png", tileable: true)
    @scrolls = 0
    @height_map = Array.new(POINTS_Y) { Array.new(POINTS_X) { rand } }
  end

  def scroll
    @scrolls += 1
    if @scrolls == SCROLLS_PER_STEP
      @scrolls = 0
      @height_map.shift
      @height_map.push Array.new(POINTS_X) { rand }
    end
  end

  def draw(z)
    # gl will execute the given block in a clean OpenGL environment, then reset
    # everything so Gosu's rendering can take place again.
    Gosu.gl(z) { exec_gl }
  end

  private

  include OpenGL

  def exec_gl
    glClearColor(0.0, 0.2, 0.5, 1.0)
    glClearDepth(0)
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    # Get the name of the OpenGL texture the Image resides on, and the
    # u/v coordinates of the rect it occupies.
    # gl_tex_info can return nil if the image was too large to fit onto
    # a single OpenGL texture and was internally split up.
    info = @image.gl_tex_info
    return unless info

    # Pretty straightforward OpenGL code.

    glDepthFunc(GL_GEQUAL)
    glEnable(GL_DEPTH_TEST)
    glEnable(GL_BLEND)

    glMatrixMode(GL_PROJECTION)
    glLoadIdentity
    glFrustum(-0.10, 0.10, -0.075, 0.075, 1, 100)

    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity
    glTranslatef(0, 0, -4)

    glEnable(GL_TEXTURE_2D)
    glBindTexture(GL_TEXTURE_2D, info.tex_name)

    offs_y = 1.0 * @scrolls / SCROLLS_PER_STEP

    0.upto(POINTS_Y - 2) do |y|
      0.upto(POINTS_X - 2) do |x|
        glBegin(GL_TRIANGLE_STRIP)
          z = @height_map[y][x]
          glColor4d(1, 1, 1, z)
          glTexCoord2d(info.left, info.top)
          glVertex3d(-0.5 + (x - 0.0) / (POINTS_X-1), -0.5 + (y - offs_y - 0.0) / (POINTS_Y-2), z)

          z = @height_map[y+1][x]
          glColor4d(1, 1, 1, z)
          glTexCoord2d(info.left, info.bottom)
          glVertex3d(-0.5 + (x - 0.0) / (POINTS_X-1), -0.5 + (y - offs_y + 1.0) / (POINTS_Y-2), z)

          z = @height_map[y][x + 1]
          glColor4d(1, 1, 1, z)
          glTexCoord2d(info.right, info.top)
          glVertex3d(-0.5 + (x + 1.0) / (POINTS_X-1), -0.5 + (y - offs_y - 0.0) / (POINTS_Y-2), z)

          z = @height_map[y+1][x + 1]
          glColor4d(1, 1, 1, z)
          glTexCoord2d(info.right, info.bottom)
          glVertex3d(-0.5 + (x + 1.0) / (POINTS_X-1), -0.5 + (y - offs_y + 1.0) / (POINTS_Y-2), z)
        glEnd
      end
    end
  end
end

# Roughly adapted from the tutorial game. Always faces north.
class Player
  Speed = 7

  attr_reader :score

  def initialize(x, y)
    @image = Gosu::Image.new("media/starfighter.bmp")
    @beep = Gosu::Sample.new("media/beep.wav")
    @x, @y = x, y
    @score = 0
  end

  def move_left
    @x = [@x - Speed, 0].max
  end

  def move_right
    @x = [@x + Speed, WIDTH].min
  end

  def accelerate
    @y = [@y - Speed, 50].max
  end

  def brake
    @y = [@y + Speed, HEIGHT].min
  end

  def draw
    @image.draw(@x - @image.width / 2, @y - @image.height / 2, ZOrder::Player)
  end

  def collect_stars(stars)
    stars.reject! do |star|
      if Gosu.distance(@x, @y, star.x, star.y) < 35
        @score += 10
        @beep.play
        true
      else
        false
      end
    end
  end
end

# Also taken from the tutorial, but drawn with draw_rot and an increasing angle
# for extra rotation coolness!
class Star
  attr_reader :x, :y

  def initialize(animation)
    @animation = animation
    @color = Gosu::Color.new(0xff_000000)
    @color.red = rand(255 - 40) + 40
    @color.green = rand(255 - 40) + 40
    @color.blue = rand(255 - 40) + 40
    @x = rand * 800
    @y = 0
  end

  def draw
    img = @animation[Gosu.milliseconds / 100 % @animation.size];
    img.draw_rot(@x, @y, ZOrder::Stars, @y, 0.5, 0.5, 1, 1, @color, :add)
  end

  def update
    # Move towards bottom of screen
    @y += 3
    # Return false when out of screen (gets deleted then)
    @y < 650
  end
end

class OpenGLIntegration < (Example rescue Gosu::Window)
  def initialize
    super WIDTH, HEIGHT

    self.caption = "OpenGL Integration"

    @gl_background = GLBackground.new

    @player = Player.new(400, 500)

    @star_anim = Gosu::Image::load_tiles("media/star.png", 25, 25)
    @stars = Array.new

    @font = Gosu::Font.new(20)
  end

  def update
    @player.move_left  if Gosu.button_down? Gosu::KB_LEFT  or Gosu.button_down? Gosu::GP_LEFT
    @player.move_right if Gosu.button_down? Gosu::KB_RIGHT or Gosu.button_down? Gosu::GP_RIGHT
    @player.accelerate if Gosu.button_down? Gosu::KB_UP    or Gosu.button_down? Gosu::GP_UP
    @player.brake      if Gosu.button_down? Gosu::KB_DOWN  or Gosu.button_down? Gosu::GP_DOWN

    @player.collect_stars(@stars)

    @stars.reject! { |star| !star.update }

    @gl_background.scroll

    @stars.push(Star.new(@star_anim)) if rand(20) == 0
  end

  def draw
    @player.draw
    @stars.each { |star| star.draw }
    @font.draw_text("Score: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
    @gl_background.draw(ZOrder::Background)
  end
end

OpenGLIntegration.new.show if __FILE__ == $0