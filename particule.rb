class Particule < Omega::Sprite

    def initialize(sprite, size)
        super(sprite)
        @sprite = sprite
        @size = size
        @lifetime = 0
        self.set_origin(0.5)
    end

    def update()
        @lifetime -= 1
        if @lifetime == 0
            $misc.delete(self)
        end
    end

    def draw()
        super
    end

    def emit_at(x, y)
        tmp = self.class.new()
        tmp.x = x
        tmp.y = y
        $misc << tmp
    end

end

class Clear < Particule

    def initialize()
        super("assets/textures/misc/clear_bullet.png", 32)
        @lifetime = 100
    end

    def update()
        @scale.x += 0.1
        @scale.y += 0.1
        @color.alpha -= 10
        super
    end

end

class Star < Particule

    module Variant
        RED = 0
        MAGENTA = 1
        BLUE = 2
        CYAN = 3
        GREEN = 4
        YELLOW = 5
    end

    def initialize()
        super("assets/textures/misc/star.png", 16)
        @lifetime = 100

        @variants = []
        for i in 0...6
            @variants[i] = self.image.subimage(0, @size * i, @size, @size)
        end
        @variant = rand(0...6)
        @angle = rand(0...360)
        set_scale(2)
    end

    def update()
        @color.alpha -= 5
        self.x += 10 * Math::cos(Omega::to_rad(@angle))
        self.y += 10 * Math::sin(Omega::to_rad(@angle))
        super
    end

    def draw()
        if not @variants[@variant].nil?
            @variants[@variant].draw_rot((@flip.x) ? @position.x + @width * @scale.x - @width*2 * @scale.x * @origin.x : @position.x,
            (@flip.y) ? @position.y + @height * @scale.y - @height*2 * @scale.y * @origin.y : @position.y,
            @position.z,
            @angle,
            @origin.x,
            @origin.y,
            (@flip.x) ? -@scale.x : @scale.x,
            (@flip.y) ? -@scale.y : @scale.y,
            @color,
            @mode) if @visible
        end
    end

end
