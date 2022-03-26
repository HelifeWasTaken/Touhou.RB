module Omega

    class Drawable
        def initialize
            @position = Omega::Vector3.new(0, 0, 0)
            @color = Omega::Color.from_color(Omega::Color::WHITE)
        end

        def alpha
            return @color.alpha
        end

        def alpha=(nv)
            @color = Omega::Color.new(nv, @color.red, @color.green, @color.blue)
        end

        def red
            return @color.red
        end

        def red=(r)
            @color.red = r
        end

        def green
            return @color.green
        end

        def green=(g)
            @color.green = g
        end

        def blue
            return @color.blue
        end

        def blue=(b)
            @color.blue = b
        end


        # Getters & setters

        # Shortcut to postion.x, position.y & position.z
        def x
            @position.x
        end

        def y
            @position.y
        end

        def z
            @position.z
        end

        def x=(v)
            @position.x = v
        end

        def y=(v)
            @position.y = v
        end

        def z=(v)
            @position.z = v
        end

        def set_position(x, y=nil, z=nil)
            y = @position.y if not y
            z = @position.z if not z

            @position = Omega::Vector3.new(x, y, z)
        end

        def set_scale(x, y=nil)
            y = x if not y
            @scale = Omega::Vector2.new(x, y)
        end

        def set_origin(x, y=nil)
            y = x if not y
            @origin = Omega::Vector2.new(x, y)
        end

        def alpha=(alpha)
            @color._alpha = alpha
        end

        def alpha
            @color.alpha
        end
    end

end
