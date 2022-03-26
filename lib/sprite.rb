module Omega

    class Sprite < Omega::Drawable

        attr_accessor :position, :scale, :origin, :flip
        attr_accessor :angle, :mode, :color
        attr_accessor :width, :height
        attr_accessor :visible

        attr_accessor :movable

        attr_reader :options, :image

        # Options
        # - Standard Gosu options
        # - :reloard => Force the API to reload the image from the hard drive
        def initialize(source, options = {})

            @@images ||= {}

            if source.is_a? String
                if not options[:reload]
                    @@images[source] ||= Gosu::Image.new(source, options)
                else
                    @@images[source] = Gosu::Image.new(source, options)
                end

                @image = @@images[source]
            elsif not source.is_a? Array
                @image = Gosu::Image.new(source, options)
            end

            @options = options

            @position = Vector3.new(0.0, 0.0, 0.0)
            @scale = Vector2.new(1.0, 1.0)
            @origin = Vector2.new(0.0, 0.0)
            @flip = Vector2.new(false, false)

            @angle = 0.0
            @mode = :default
            @color = Omega::Color.copy(Omega::Color::WHITE)

            if @image
                @width = @image.width
                @height = @image.height
            end

            @visible = true

            @movable = true
        end

        def update; end

        def draw
            @image.draw_rot((@flip.x) ? @position.x + @width * @scale.x - @width*2 * @scale.x * @origin.x : @position.x,
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

        # Utils functions
        def set_center(axe_x, axe_y)
            @position.x = (Omega.window.width - @width*@scale.x) / 2 if axe_x
            @position.y = (Omega.window.height - @height*@scale.y) / 2 if axe_y
            @position.x += @width.to_f*@scale.x*@origin.x
            @position.y += @height.to_f*@scale.y*@origin.y
        end

        def collides?(sprite)
            Omega.log_err("This is not a sprite.") if not sprite.is_a? Sprite

            # puts @position.x
            # puts sprite.x + (sprite.width.to_f*sprite.scale.x) - (sprite.width.to_f*sprite.scale.x*sprite.origin.x)
            if @position.x > sprite.x + (sprite.width.to_f*sprite.scale.x) - (sprite.width.to_f*sprite.scale.x*sprite.origin.x) or
               @position.x + (@width.to_f*@scale.x) + (@width.to_f*@scale.x*@origin.x) < sprite.x - (sprite.width.to_f*sprite.scale.x*sprite.origin.x) or
               @position.y > sprite.y + (sprite.height.to_f*sprite.scale.y) - (sprite.height.to_f*sprite.scale.y*sprite.origin.y) or
               @position.y + (@height.to_f*@scale.y) - (@height.to_f*@scale.y*@origin.y) < sprite.y - (sprite.height.to_f*sprite.scale.y*sprite.origin.y)
                return false
            end

            true
            # false
        end

        def pixel_at(x, y)
            @blob ||= @image.to_blob
			if x < 0 or x >= width or y < 0 or y >= height
				return nil
			else
                return Omega::Color.new(@blob[(y * @width + x) * 4, 4][3].unpack("H*").first.to_i(16),
                                       @blob[(y * @width + x) * 4, 4][1].unpack("H*").first.to_i(16), 
                                       @blob[(y * @width + x) * 4, 4][2].unpack("H*").first.to_i(16),
                                       @blob[(y * @width + x) * 4, 4][0].unpack("H*").first.to_i(16))
			end
        rescue
            nil
        end
        
        def subimage(x, y, width, height)
            return @image.subimage(x, y, width, height)
        end

        def width_scaled
            return @width * @scale.x
        end

        def height_scaled
            return @height * @scale.y
        end

        def alpha
            return @color.alpha
        end

        def alpha=(nv)
            @color._alpha = nv
        end

        def set_alpha(nv)
            @color._alpha = nv
        end

        def set_position(x, y=nil, z=nil)
            y = @position.y if not y
            z = @position.z if not z

            @position = Omega::Vector3.new(x, y, z)
        end

        # Debug only functions

        def debug_move(speed = 5)
            if Omega::pressed(Gosu::KB_RIGHT)
                @position.x += speed
            elsif Omega::pressed(Gosu::KB_LEFT)
                @position.x -= speed
            end
            
            if Omega::pressed(Gosu::KB_UP)
                @position.y -= speed
            elsif Omega::pressed(Gosu::KB_DOWN)
                @position.y += speed
            end
        end
    end

    class SpriteSheet < Sprite
        attr_reader :frame_width, :frame_height, :current_animation, :frames_count, :frames

        attr_accessor :current_frame, :frame_speed, :loop

        attr_accessor :animations

        def initialize(source, width, height, options = {})
            super(source, options)

            if source.is_a? Array
                @frames = source
            else
                @frames = Gosu::Image.load_tiles(@image, width, height, options)
            end
            @frames_count = @frames.size
            @current_frame = 0
            @frame_speed = 0.1

            @width = width
            @height = height

            @animations = {}
            @animations_speed = {}
            @current_animation = nil

            @pause = false
            @loop = true
        end

        def draw(can_add_frame = true)
            if @current_animation != nil
                if @frame_speed != 0 and not @pause and can_add_frame
                    @current_frame += ((@animations_speed[@current_animation]) ? @animations_speed[@current_animation] : @frame_speed)
                    if @loop
                        @current_frame %= @animations[@current_animation].size
                    else
                        last_frame = (@animations[@current_animation].size - 1)
                        @current_frame = last_frame if @current_frame > last_frame
                    end
                end
                
                @frames[@animations[@current_animation][@current_frame.to_i]].draw_rot((@flip.x) ? @position.x + @width * @scale.x - @width*2 * @scale.x * @origin.x : @position.x,
                                                                                        (@flip.y) ? @position.y + @height * @scale.y - @height*2 * @scale.y * @origin.y : @position.y,
                                                                                        @position.z,
                                                                                        @angle,
                                                                                        @origin.x,
                                                                                        @origin.y,
                                                                                        (@flip.x) ? -@scale.x : @scale.x,
                                                                                        (@flip.y) ? -@scale.y : @scale.y,
                                                                                        @color,
                                                                                        @mode)
            else
                @frames[@current_frame].draw_rot((@flip.x) ? @position.x + @width * @scale.x - @width*2 * @scale.x * @origin.x : @position.x,
                                                 (@flip.y) ? @position.y + @height * @scale.y - @height*2 * @scale.y * @origin.y : @position.y,
                                                 @position.z,
                                                 @angle,
                                                 @origin.x,
                                                 @origin.y,
                                                 (@flip.x) ? -@scale.x : @scale.x,
                                                 (@flip.y) ? -@scale.y : @scale.y,
                                                 @color,
                                                 @mode)
            end if @visible
        end

        def add_animation(id, array, speed = nil)
            @animations[id] = array
            @animations_speed[id] = speed
        end

        def set_animation_speed(id, speed)
            @animations_speed[id] = speed
        end

        def play_animation(id, loop_anim = true)
            @current_frame = 0
            @current_animation = id
            @loop = loop_anim
        end

        def stop
            @current_frame = 0
            @current_animation = nil
        end

        def pause
            @pause = true
        end

        def resume
            @pause = false
        end

        def frame
            return @animations[@current_animation][@current_frame.to_i]
        end

        def finished?
            return (@animations[@current_animation] and
                    @current_frame == (@animations[@current_animation].size - 1) and
                    not @loop)
        end

        def pixel_at(x, y)
            @blob ||= {}
            @blob[@current_frame] ||= @frames[@current_frame].to_blob
			if x < 0 or x >= width or y < 0 or y >= height
				return nil
			else
                return Omega::Color.new(@blob[@current_frame][(y * @width + x) * 4, 4][3].unpack("H*").first.to_i(16),
                                       @blob[@current_frame][(y * @width + x) * 4, 4][1].unpack("H*").first.to_i(16), 
                                       @blob[@current_frame][(y * @width + x) * 4, 4][2].unpack("H*").first.to_i(16),
                                       @blob[@current_frame][(y * @width + x) * 4, 4][0].unpack("H*").first.to_i(16))
			end
        rescue
            nil
        end
    end

end