module Omega

    class Camera < Drawable
        attr_accessor :position, :origin, :scale, :integer_position, :lerp
        attr_reader :locked_x, :locked_y

        def initialize(lock_to_zero = true)
            @scale = Vector2.new(1, 1)
            @position = Vector2.new(0, 0)

            @sprite_to_follow = nil
            @lerp = 0.2

            @angle = 0.0
            @origin = Vector2.new(0, 0)

            @shake_pos = []

            @sprite_follow_angle = false

            @lock_to_zero = lock_to_zero

            @locked_x = false
            @locked_y = false

            @integer_position = Omega::Vector2.new(false, false)
        end

        def draw(width = Omega.width/@scale.x, height = Omega.height/@scale.y, map_width = nil, map_height = nil)

            shake_pos = Omega::Vector2.new(0, 0)

            if @shake_pos.size > 0
                shake_pos = @shake_pos[-1].clone
                @shake_pos.pop
            end

            if @sprite_to_follow
                px = -(@sprite_to_follow.position.x - (width-@sprite_to_follow.width_scaled)/2 - @sprite_to_follow.width_scaled*@sprite_to_follow.origin.x)
                py = -(@sprite_to_follow.position.y - (height-@sprite_to_follow.height_scaled)/2 - @sprite_to_follow.height_scaled*@sprite_to_follow.origin.y)
                @position.x -= (@position.x - px) * @lerp
                @position.y -= (@position.y - py) * @lerp

                # @position.x = -@position.x + (width - @sprite_to_follow.width*@sprite_to_follow.scale.x) / 2
                # @position.y = -@position.y + (height - @sprite_to_follow.height*@sprite_to_follow.scale.y) / 2

                if @sprite_follow_angle
                    @origin = Vector2.new(width/2, height/2)
                    @angle = -@sprite_to_follow.angle - 90
                end
            end

            @position.x = 0 if @position.x > 0 and @lock_to_zero
            @position.y = 0 if @position.y > 0 and @lock_to_zero

            # @position.x = 0 if -@position.x < 0
            @locked_x = false

            if -@position.x < 0 and @sprite_to_follow
                x = 0
                @locked_x = true
            end
            
            if -@position.x < 0 and @sprite_to_follow
                y = 0
                @locked_y = true
            end

            if map_width and -@position.x + width*@scale.x*0.5 > map_width
                @position.x = -(map_width - width*@scale.x*0.5)
                @locked_x = true
            end

            if map_height and -@position.y + height*@scale.y*0.5 > map_height
                @position.y = -(map_height - height*@scale.y*0.5)
                @locked_y = true
            end

            fx = @position.x + shake_pos.x
            fx = fx.to_i if @integer_position.x

            fy = @position.y + shake_pos.y
            fy = fy.to_i if @integer_position.y

            Gosu.rotate(@angle, @origin.x, @origin.y) do
                Gosu.scale(@scale.x, @scale.y) do
                    Gosu.translate(fx, fy) do
                        yield @position
                    end
                end
            end
        end

        def follow(sprite, lerp, sprite_follow_angle = false)
            @lerp = lerp
            if @sprite_to_follow
                @angle = 0.0
                @origin = Vector2.new(0, 0)
            end
            @sprite_to_follow = sprite
            @sprite_follow_angle = sprite_follow_angle
        end

        def stop_follow
            @lerp = 1
            @sprite_to_follow = nil
            @sprite_follow_angle = nil
        end

        def shake(duration, min_offset, max_offset)
            duration.times do
                @shake_pos << Omega::Vector2.new(rand(min_offset..max_offset), rand(min_offset..max_offset))
            end
        end

        def shake_finished
            return @shake_pos.size == 0
        end

        def is_visible(sprite, width = Omega.width, height = Omega.height)
            if (sprite.position.x + sprite.width * sprite.scale.x > -@position.x and sprite.position.x < -@position.x + width/@scale.x and
                sprite.position.y + sprite.height * sprite.scale.y > -@position.y and sprite.position.y < -@position.y + height/@scale.y)
                return true
            end

            return false
        end
    end

end