module Omega

    class Rectangle < Omega::Drawable
        attr_accessor :position, :width, :height, :color

        def initialize(x, y, width, height)
            @position = Omega::Vector3.new(x, y, 0)
            @color = Omega::Color.copy(Omega::Color::WHITE)
            @width = width
            @height = height
        end

        def collides?(rect)
            if @position.x > rect.position.x + rect.width or
                @position.x + @width < rect.position.x or
                @position.y > rect.position.y + rect.height or
                @position.y + @height < rect.position.y
                return false
            end
            return true
        end

        def point_collides?(position)
            if position.x >= @position.x and position.x <= @position.x + @width and
                position.y >= @position.y and position.y <= @position.y + @height
                return true
            end
            return false
        end

        def draw
            Gosu.draw_rect(@position.x, @position.y, @width, @height, @color, @position.z)
        end

        def to_s
          return "Rectangle(x: " + @position.x.to_s + ", y: " + @position.y.to_s + ", h: " + @height.to_s + ", w: " + @width.to_s + ")"
        end

    end

end
