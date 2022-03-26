module Omega

    class Parallax < Drawable

        attr_accessor :position, :sprites
        attr_accessor :scale
        attr_accessor :width, :height
        attr_accessor :offset_modifier
        attr_accessor :bg_loop
        attr_accessor :color
        attr_accessor :z_layer

        def initialize(sprites)
            @sprites = sprites
            @width = sprites[0].width
            @height = sprites[0].height
            @position = Omega::Vector3.new(0, 0, 0)
            @scale = Omega::Vector2.new(1, 1)
            @offset_modifier = 1
            @color = Omega::Color.copy(Gosu::Color::WHITE)
            @z_layer = 0

            @bg_loop = true
        end

        def draw(borders = 1)
            offset = @offset_modifier
            i = 0
            @sprites.each do |spr|
                x = (@position.x*offset)
                y = (@position.y*offset)
                z = (@position.z + i * @z_layer)

                if @bg_loop
                    x %= (@width*@scale.x)
                    y %= (@height*@scale.y)
                end
                spr.image.draw(x, y, z, @scale.x, @scale.y, @color)
                borders.times do |b|
                    spr.image.draw(x-@width*@scale.x*(b+1), y, z, @scale.x, @scale.y, @color)
                    spr.image.draw(x+@width*@scale.x*(b+1), y, z, @scale.x, @scale.y, @color)

                    spr.image.draw(x, y-@height*@scale.y*(b+1), z, @scale.x, @scale.y, @color)
                    spr.image.draw(x-@width*@scale.x*(b+1), y-@height*@scale.y*(b+1), z, @scale.x, @scale.y, @color)
                    spr.image.draw(x+@width*@scale.x*(b+1), y-@height*@scale.y*(b+1), z, @scale.x, @scale.y, @color)

                    spr.image.draw(x, y+@height*@scale.y*(b+1), z, @scale.x, @scale.y, @color)
                    spr.image.draw(x-@width*@scale.x*(b+1), y+@height*@scale.y*(b+1), z, @scale.x, @scale.y, @color)
                    spr.image.draw(x+@width*@scale.x*(b+1), y+@height*@scale.y*(b+1), z, @scale.x, @scale.y, @color)
                end
                offset *= @offset_modifier
                i += 1
            end
        end

        def draw_horizontal(borders = 1)
            offset = @offset_modifier
            @sprites.each do |spr|
                x = (@position.x*offset)

                if @bg_loop
                    x %= (@width*@scale.x)
                end
                spr.image.draw(x, @position.y, @position.z, @scale.x, @scale.y, @color)
                borders.times do |b|
                    spr.image.draw(x-@width*@scale.x*(b+1), @position.y, @position.z, @scale.x, @scale.y, @color)
                    spr.image.draw(x+@width*@scale.x*(b+1), @position.y, @position.z, @scale.x, @scale.y, @color)
                end
                offset *= @offset_modifier
            end
        end

        def draw_vertical(borders = 1)
            offset = @offset_modifier
            @sprites.each do |spr|
                y = (@position.y*offset)

                if @bg_loop
                    y %= (@height*@scale.y)
                end
                spr.image.draw(@position.x, y, @position.z, @scale.x, @scale.y, @color)
                borders.times do |b|
                    spr.image.draw(@position.x, y-@height*@scale.y*(b+1), @position.z, @scale.x, @scale.y, @color)
                    spr.image.draw(@position.x, y+@height*@scale.y*(b+1), @position.z, @scale.x, @scale.y, @color)
                end
                offset *= @offset_modifier
            end
        end

        def change_sprites(sprites)
            @sprites = sprites
        end
    end

end
