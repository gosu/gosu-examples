# Encoding: UTF-8

# Based on the C Demo3 demonstration distributed with Chipmunk.
# Also with some help from the chipmunk_integration.rb program.
#
# License: Same as for Gosu (MIT)
# Created on 21/10/2007, 00:05:19 by Robert Sheehan

require "gosu"
require "chipmunk"
require "rmagick"

# Layering of sprites
module ZOrder
  BACKGROUND, BOX = *0..1
end

WIDTH = 640
HEIGHT = 480
TICK = 1.0/60.0
NUM_POLYGONS = 80
NUM_SIDES = 4
EDGE_SIZE = 15

class ChipmunkAndRMagick < (Example rescue Gosu::Window)
  def radians_to_vec2(radians)
    CP::Vec2.new(Math::cos(radians), Math::sin(radians))
  end
  
  def initialize
    super WIDTH, HEIGHT
    
    self.caption = "Chipmunk, RMagick and Gosu"
    
    @space = CP::Space.new
    @space.iterations = 5
    @space.gravity = CP::Vec2.new(0, 100)
    
    # you can replace the background with any image with this line
    # background = Magick::ImageList.new("media/space.png")
    fill = Magick::TextureFill.new(Magick::ImageList.new("granite:"))
    background = Magick::Image.new(WIDTH, HEIGHT, fill)
    setup_triangles(background)
    @background_image = Gosu::Image.new(background, tileable: true) # turn the image into a Gosu one
    @boxes = create_boxes(NUM_POLYGONS)
  end
  
  # Create all of the static triangles.
  # Adds them to the space and the background image.
  def setup_triangles(background)
    gc = Magick::Draw.new
    gc.stroke_width(2)
    gc.stroke("red")
    gc.fill("blue")
    # all the triangles are part of the same body
    body = CP::Body.new(Float::MAX, Float::MAX)
    base = 15
    height = 10
    shape_vertices =  [CP::Vec2.new(-base, base), CP::Vec2.new(base, base), CP::Vec2.new(0, -height)]
    # make shapes and images
    8.times do |i|
      8.times do |j|
        stagger = (j % 2) * 40
        x = i * 80 + stagger
        y = j * 70 + 80
        shape = CP::Shape::Poly.new(body, shape_vertices, CP::Vec2.new(x, y))
        shape.e = 1
        shape.u = 1
        @space.add_static_shape(shape)
        gc.polygon(x - base + 1, y + base - 1, x + base - 1, y + base - 1,  x, y - height + 1)
      end
    end
    # do the drawing
    gc.draw(background)
  end

  # Produces the vertices of a regular polygon.
  def polygon_vertices(sides, size)
    vertices = []
    sides.times do |i|
      angle = -2 * Math::PI * i / sides
      vertices << radians_to_vec2(angle) * size
    end
    return vertices
  end
  
  # Produces the image of a polygon.
  def polygon_image(vertices)
    box_image = Magick::Image.new(EDGE_SIZE  * 2, EDGE_SIZE * 2) { self.background_color = "transparent" }
    gc = Magick::Draw.new
    gc.stroke("red")
    gc.fill("plum")
    draw_vertices = vertices.map { |v| [v.x + EDGE_SIZE, v.y + EDGE_SIZE] }.flatten
    gc.polygon(*draw_vertices)
    gc.draw(box_image)
    return Gosu::Image.new(box_image)
  end
  
  # Produces the polygon objects and adds them to the space.
  def create_boxes(num)
    box_vertices = polygon_vertices(NUM_SIDES, EDGE_SIZE)
    box_image = polygon_image(box_vertices)
    boxes =  []
    num.times do
      body = CP::Body.new(1, CP::moment_for_poly(1.0, box_vertices, CP::Vec2.new(0, 0))) # mass, moment of inertia
      body.p = CP::Vec2.new(rand(WIDTH), rand(40) - 50)
      shape = CP::Shape::Poly.new(body, box_vertices, CP::Vec2.new(0, 0))
      shape.e = 0.0
      shape.u = 0.4
      boxes << Box.new(box_image, body)
      @space.add_body(body)
      @space.add_shape(shape)      
    end
    return boxes
  end
  
  # All the simulation is done here.
  def update
    @space.step(TICK)
    @boxes.each { |box| box.check_off_screen }
  end
  
  # All the updating of the screen is done here.
  def draw
    @background_image.draw(0, 0, ZOrder::BACKGROUND)
    @boxes.each { |box| box.draw }
  end
end

# The falling boxes class.
# Nothing more than a body and an image.
class Box
  def initialize(image, body)
    @image = image
    @body = body
  end
  
  # If it goes offscreen we put it back to the top.
  def check_off_screen
    pos = @body.p
    if pos.y > HEIGHT + EDGE_SIZE or pos.x > WIDTH + EDGE_SIZE or pos.x < -EDGE_SIZE
      @body.p = CP::Vec2.new(rand * WIDTH, 0)
    end
  end
  
  def draw
    @image.draw_rot(@body.p.x, @body.p.y, ZOrder::BOX, @body.a.radians_to_gosu)
  end
end

ChipmunkAndRMagick.new.show if __FILE__ == $0
