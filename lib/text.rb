module Omega
    class Text < Drawable
        attr_accessor :position, :scale, :text, :color, :mode, :active

        module WindowPos
            MIDDLE = 0
            LEFT = 1
            RIGHT = 2
            UP = 3
            DOWN = 4
            LEFTUP = 5
            RIGHTUP = 6
            LEFTDOWN = 7
            RIGHTDOWN = 8
        end

        def initialize(text, font, scale = Omega::Vector2.new(1, 1), z_layer = 1)
            @@fonts ||= {}
            change_font(font.name, font.height)
            @position = Omega::Vector3.new(0, 0, z_layer)
            @scale = scale
            @text = text
            @color = Gosu::Color::WHITE
            @mode = :default
            @active = true
        end

        def draw
            if (@active)
                @font.draw_markup(@text,
                                 @position.x,
                                 @position.y,
                                 @position.z,
                                 @scale.x,
                                @scale.y,
                                @color,
                                @mode)
            end
        end

        def draw_at_pos(pos, x_offset, y_offset, width = Omega.width, height = Omega.height)
            game_width = width
            game_heigth = height
            text_width = @font.text_width(@text) * @scale.y
            text_heigth = @font.height * @scale.x * @text.split("\n").size

            case pos
                when WindowPos::MIDDLE
                    @position.x = (game_width / 2) - (text_width / 2) + x_offset
                    @position.y = (game_heigth / 2) - (text_heigth / 2) + y_offset
                when WindowPos::LEFT
                    @position.x = x_offset
                    @position.y = (game_heigth / 2) - (text_heigth / 2) + y_offset
                when WindowPos::RIGHT
                    @position.x = game_width - text_width + x_offset
                    @position.y = (game_heigth / 2) - (text_heigth / 2) + y_offset
                when WindowPos::UP
                    @position.x = (game_width / 2) - (text_width / 2) + x_offset
                    @position.y = y_offset
                when WindowPos::DOWN
                    @position.x = (game_width / 2) - (text_width / 2) + x_offset
                    @position.y = game_heigth - text_heigth + y_offset
                when WindowPos::LEFTUP
                    @position.x = x_offset
                    @position.y = y_offset
                when WindowPos::RIGHTUP
                    @position.x = game_width - text_width + x_offset
                    @position.y = y_offset
                when WindowPos::LEFTDOWN
                    @position.x = x_offset
                    @position.y = game_heigth - text_heigth + y_offset
                when WindowPos::RIGHTDOWN
                    @position.x = game_width - text_width + x_offset
                    @position.y = game_heigth - text_heigth + y_offset
                else
                    raise "Bro r u dumb ?"
            end
            draw()
        end

        def change_font(path, size)
            path = "default" if path.size == 0
            if not @@fonts[path+"_#{size}"]
                if path == "default"
                    @@fonts[path+"_#{size}"] = Gosu::Font.new(size)
                else
                    @@fonts[path+"_#{size}"] = Gosu::Font.new(size, name: path)
                end
            end

            @font = @@fonts[path+"_#{size}"]
        end

        def toggle
            if (is_active())
                @active = false
            else
                @active = true
            end
        end

        def window_pos
            return @window_pos
        end

        def width
            return @font.text_width(@text) * @scale.x
        end

        def height
            return @font.height * @scale.y * @text.split("\n").size
        end

        def alpha=(alpha)
            @color = Gosu::Color.new(alpha, @color.red, @color.green, @color.blue)
        end

        def alpha
            return @color.alpha
        end

        def is_active
            return @active
        end
    end
end
