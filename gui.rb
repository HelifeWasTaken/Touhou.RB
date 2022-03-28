class GUI

    attr_accessor :active

    def initialize()
        @widgets = []
        @active = true
        @pos = Omega::Vector2.new(0, 0)
    end

    def add(*widget)
        @widgets += widget
        return self
    end

    def at(x, y)
        @pos = Omega::Vector2.new(x, y)
        return self
    end

    def update()
        if @active == false
            return
        end
        for widget in @widgets
            widget.update()
        end
    end

    def draw()
        if @active == false
            return
        end
        for widget in @widgets
            widget.draw(@pos.x, @pos.y)
        end
    end

end

class GUIHandler

    def initialize()
        @guis = {}
        @trigger = {}
        @gui_stack = []
    end

    def add(id, gui, *trigger)
        @guis[id] = gui
        @trigger[id] = Trigger.new(trigger)
        return self
    end

    def stack_up()
        for key in @trigger.keys
            @trigger[key].check()
            if @trigger[key].is_trigered?
                @gui_stack << @guis[key]
            end
        end
    end

    def update()
        stack_up()
        for gui in @gui_stack
            gui.update()
        end
    end

    def draw()
        for gui in @gui_stack
            gui.draw()
        end
    end

end

class Trigger

    attr_accessor :no_reset

    def initialize(*event, no_reset)
        @no_reset = no_reset
        @event += event
        @trigered = false
    end

    def reset()
        if @no_reset
            return
        end
        @trigered = false
    end

    def check()
        for e in @event
            if e.is_true?
                @trigered = true
            end
        end
    end

    def is_trigered?()
        return @trigered
    end

end

class GUIEvent

    def initialize(func)
        @func = func
    end

    def is_true?()
        return @func.call()
    end

end

class Widget

    attr_accessor :pos, :size, :tile_size, :scale, :offset

    def initialize()
        @pos = Omega::Vector2.new(0, 0)
        @size = Omega::Vector2.new(0, 0)
        @tile_size = 0
        @texture = nil
        @image = nil
        @rect = Omega::Rectangle.new(0, 0, 0, 0)
        @scale = Omega::Vector2.new(1, 1)
        @offset = 0
    end

    def reload()
        @rect.x = @pos.x
        @rect.y = @pos.y
        @rect.width = @size.x * @tile_size * @scale.x
        @rect.height = @size.y * @tile_size * @scale.y
    end

    def at(x, y)
        @pos = Omega::Vector2.new(x, y)
        reload()
        return self
    end

    def size(width, height)
        @size = Omega::Vector2.new(width, height)
        reload()
        return self
    end

    def tile_size(size)
        @tile_size = size
        reload()
        return self
    end

    def scale(x, y)
        @scale = Omega::Vector2.new(x, y)
        reload()
        return self
    end

    def display(texture_path)
        @texture = texture_path
        @image = Gosu::Image.load_tiles(@texture, @tile_size, @tile_size, {})
        return self
    end

    def on_click(); end

    def on_hover(); end

    def on_input(); end

    def update()
        self.on_click()
        self.on_hover()
        self.on_input()
    end

    def draw(x, y); end

    def to_s
        puts "Widget<#{@rect.x}x#{@rect.y} | #{@rect.width}x#{@rect.height}>"
    end

end

class Text < Widget

    def initialize(text)
        super()
        @text = text
        @font = nil
        @data = nil
    end

    def reload()
        @rect.x = @pos.x
        @rect.y = @pos.y
        @rect.width = @size.x * @tile_size * @scale.x
        @rect.height = @size.y * @tile_size * @scale.y
        if @font != nil
            @data = Omega::Text.new(@text, @font)
        end
        if @data != nil
            @data.scale = @scale
        end
    end

    def font(font)
        @font = font
        reload()
        return self
    end

    def write(text)
        @text = text
        reload()
        return self
    end

    def at(x, y)
        @pos = Omega::Vector2.new(x, y)
        reload()
        return self
    end

    def size(width, height); end

    def tile_size(size); end

    def scale(x, y)
        @scale = Omega::Vector2.new(x, y)
        reload()
        return self
    end

    def display(texture_path); end

    def on_click(); end

    def on_hover(); end

    def on_input(); end

    def draw(x, y)
        if @data != nil
            @data.draw_at_pos(Omega::Text::WindowPos::LEFTUP, x + @pos.x * @scale.x, y + @pos.y * @scale.y)
        end
    end

    def to_s
        puts "Widget<#{@rect.x}x#{@rect.y} | #{@rect.width}x#{@rect.height}>"
    end

end

class Blank < Widget

    def initialize()
        super()
    end

    def on_click()
        super()
    end

    def on_hover(); end

    def on_input(); end

    def draw(x, y)
        for tmp_x in 0...@size.x
            for tmp_y in 0...@size.y
                if tmp_x == 0
                    if tmp_y == 0
                        @image[0 + @offset].draw(x + @pos.x + tmp_x * @tile_size * @scale.x, y + @pos.y + tmp_y * @tile_size * @scale.y, 0, @scale.x, @scale.y)
                    elsif tmp_y == @size.y - 1
                        @image[6 + @offset].draw(x + @pos.x + tmp_x * @tile_size * @scale.x, y + @pos.y + tmp_y * @tile_size * @scale.y, 0, @scale.x, @scale.y)
                    else
                        @image[3 + @offset].draw(x + @pos.x + tmp_x * @tile_size * @scale.x, y + @pos.y + tmp_y * @tile_size * @scale.y, 0, @scale.x, @scale.y)
                    end
                elsif tmp_x == @size.x - 1
                    if tmp_y == 0
                        @image[2 + @offset].draw(x + @pos.x + tmp_x * @tile_size * @scale.x, y + @pos.y + tmp_y * @tile_size * @scale.y, 0, @scale.x, @scale.y)
                    elsif tmp_y == @size.y - 1
                        @image[8 + @offset].draw(x + @pos.x + tmp_x * @tile_size * @scale.x, y + @pos.y + tmp_y * @tile_size * @scale.y, 0, @scale.x, @scale.y)
                    else
                        @image[5 + @offset].draw(x + @pos.x + tmp_x * @tile_size * @scale.x, y + @pos.y + tmp_y * @tile_size * @scale.y, 0, @scale.x, @scale.y)
                    end
                else
                    if tmp_y == 0
                        @image[1 + @offset].draw(x + @pos.x + tmp_x * @tile_size * @scale.x, y + @pos.y + tmp_y * @tile_size * @scale.y, 0, @scale.x, @scale.y)
                    elsif tmp_y == @size.y - 1
                        @image[7 + @offset].draw(x + @pos.x + tmp_x * @tile_size * @scale.x, y + @pos.y + tmp_y * @tile_size * @scale.y, 0, @scale.x, @scale.y)
                    else
                        @image[4 + @offset].draw(x + @pos.x + tmp_x * @tile_size * @scale.x, y + @pos.y + tmp_y * @tile_size * @scale.y, 0, @scale.x, @scale.y)
                    end
                end
            end
        end
    end

end

class Separator < Widget

    def initialize()
        super()
    end

    def size(height)
        @size = Omega::Vector2.new(1, height)
        reload()
        return self
    end

    def on_click(); end

    def on_hover(); end

    def on_input(); end

    def draw(x, y)
        for tmp_y in 0...@size.y
            if tmp_y == 0
                @image[0].draw(x + @pos.x * @scale.x, y + @pos.y + tmp_y * @tile_size * @scale.y, 0, @scale.x, @scale.y)
            elsif tmp_y == @size.y - 1
                @image[2].draw(x + @pos.x * @scale.x, y + @pos.y + tmp_y * @tile_size * @scale.y, 0, @scale.x, @scale.y)
            else
                @image[1].draw(x + @pos.x * @scale.x, y + @pos.y + tmp_y * @tile_size * @scale.y, 0, @scale.x, @scale.y)
            end
        end
    end

end

class Popup < Widget

    attr_accessor :read

    def initialize()
        super()
        @read = false
    end

    def on_click(); end

    def on_hover(); end

    def on_input()
        if Omega::just_pressed(Gosu::KB_RETURN) && @read == false
            @read = true
        end
    end

    def draw(x, y)
        if @read
            return
        end
        for tmp_x in 0...@size.x
            for tmp_y in 0...@size.y
                if tmp_x == 0
                    if tmp_y == 0
                        @image[0 + @offset].draw(x + @pos.x + tmp_x * @tile_size * @scale.x, y + @pos.y + tmp_y * @tile_size * @scale.y, 0, @scale.x, @scale.y)
                    elsif tmp_y == @size.y - 1
                        @image[6 + @offset].draw(x + @pos.x + tmp_x * @tile_size * @scale.x, y + @pos.y + tmp_y * @tile_size * @scale.y, 0, @scale.x, @scale.y)
                    else
                        @image[3 + @offset].draw(x + @pos.x + tmp_x * @tile_size * @scale.x, y + @pos.y + tmp_y * @tile_size * @scale.y, 0, @scale.x, @scale.y)
                    end
                elsif tmp_x == @size.x - 1
                    if tmp_y == 0
                        @image[2 + @offset].draw(x + @pos.x + tmp_x * @tile_size * @scale.x, y + @pos.y + tmp_y * @tile_size * @scale.y, 0, @scale.x, @scale.y)
                    elsif tmp_y == @size.y - 1
                        @image[8 + @offset].draw(x + @pos.x + tmp_x * @tile_size * @scale.x, y + @pos.y + tmp_y * @tile_size * @scale.y, 0, @scale.x, @scale.y)
                    else
                        @image[5 + @offset].draw(x + @pos.x + tmp_x * @tile_size * @scale.x, y + @pos.y + tmp_y * @tile_size * @scale.y, 0, @scale.x, @scale.y)
                    end
                else
                    if tmp_y == 0
                        @image[1 + @offset].draw(x + @pos.x + tmp_x * @tile_size * @scale.x, y + @pos.y + tmp_y * @tile_size * @scale.y, 0, @scale.x, @scale.y)
                    elsif tmp_y == @size.y - 1
                        @image[7 + @offset].draw(x + @pos.x + tmp_x * @tile_size * @scale.x, y + @pos.y + tmp_y * @tile_size * @scale.y, 0, @scale.x, @scale.y)
                    else
                        @image[4 + @offset].draw(x + @pos.x + tmp_x * @tile_size * @scale.x, y + @pos.y + tmp_y * @tile_size * @scale.y, 0, @scale.x, @scale.y)
                    end
                end
            end
        end
    end

end

class ItemFrame < Widget

    def initialize()
        super()
        @item = nil
    end

    def on_click(); end

    def on_hover(); end

    def on_input(); end

    def frame(item)
        @item = item
        return self
    end

    def draw(x, y)
        for tmp_x in 0...@size.x
            for tmp_y in 0...@size.y
                if tmp_x == 0
                    if tmp_y == 0
                        @image[0 + @offset].draw(x + @pos.x + tmp_x * @tile_size * @scale.x, y + @pos.y + tmp_y * @tile_size * @scale.y, 0, @scale.x, @scale.y)
                    elsif tmp_y == @size.y - 1
                        @image[6 + @offset].draw(x + @pos.x + tmp_x * @tile_size * @scale.x, y + @pos.y + tmp_y * @tile_size * @scale.y, 0, @scale.x, @scale.y)
                    else
                        @image[3 + @offset].draw(x + @pos.x + tmp_x * @tile_size * @scale.x, y + @pos.y + tmp_y * @tile_size * @scale.y, 0, @scale.x, @scale.y)
                    end
                elsif tmp_x == @size.x - 1
                    if tmp_y == 0
                        @image[2 + @offset].draw(x + @pos.x + tmp_x * @tile_size * @scale.x, y + @pos.y + tmp_y * @tile_size * @scale.y, 0, @scale.x, @scale.y)
                    elsif tmp_y == @size.y - 1
                        @image[8 + @offset].draw(x + @pos.x + tmp_x * @tile_size * @scale.x, y + @pos.y + tmp_y * @tile_size * @scale.y, 0, @scale.x, @scale.y)
                    else
                        @image[5 + @offset].draw(x + @pos.x + tmp_x * @tile_size * @scale.x, y + @pos.y + tmp_y * @tile_size * @scale.y, 0, @scale.x, @scale.y)
                    end
                else
                    if tmp_y == 0
                        @image[1 + @offset].draw(x + @pos.x + tmp_x * @tile_size * @scale.x, y + @pos.y + tmp_y * @tile_size * @scale.y, 0, @scale.x, @scale.y)
                    elsif tmp_y == @size.y - 1
                        @image[7 + @offset].draw(x + @pos.x + tmp_x * @tile_size * @scale.x, y + @pos.y + tmp_y * @tile_size * @scale.y, 0, @scale.x, @scale.y)
                    else
                        @image[4 + @offset].draw(x + @pos.x + tmp_x * @tile_size * @scale.x, y + @pos.y + tmp_y * @tile_size * @scale.y, 0, @scale.x, @scale.y)
                    end
                end
            end
        end
        if @item != nil
            @item.x = x + @pos.x + (@rect.width / 2)
            @item.y = y + @pos.y + (@rect.height / 2)
            @item.scale = @scale
            @item.set_origin(0.5)
            @item.draw()
        end
    end

end

class ProgressBar < Widget

    attr_accessor :max, :value, :color

    def initialize()
        super()
        @max = 0
        @value = 0
        @color = 0xff_ffffff
        @offset = 1
        @rect = Omega::Rectangle.new(0, 0, 0, 0)
    end

    def max(value)
        @max = value
        reload()
        return self
    end

    def value(value)
        @value = value
        return self
    end

    def color(color)
        @color = color
        return self
    end

    def size(width)
        @size = Omega::Vector2.new(width, 1)
        reload()
        return self
    end

    def reload()
        # while @size.x.to_f > (@max.to_f * @offset)
        #     if @max.to_f <= 0.0
        #         break
        #     end
        #     @offset += 0.1
        # end
        super()
    end

    def on_click(); end

    def on_hover(); end

    def on_input(); end

    def draw(x, y)
        # for tmp_x in 0...[@value * @offset, @max.to_f * @offset].min()
        #     @image[3].draw(x + @pos.x + tmp_x * (@size.x / (@max.to_f * @offset)) * @tile_size * @scale.x, y + @pos.y * @scale.y, 0, @scale.x, @scale.y, @color)
        # end
        @rect.color = @color
        @rect.x = x
        @rect.y = y
        @rect.width = [@size.x * @tile_size * @scale.x * (@value.to_f / @max.to_f), 0].max
        @rect.height = @tile_size * @scale.y
        @rect.draw
        for tmp_x in 0...@size.x
            if tmp_x == 0
                @image[0].draw(x + @pos.x + tmp_x * @tile_size * @scale.x, y + @pos.y * @scale.y, 0, @scale.x, @scale.y)
            elsif tmp_x == @size.x - 1
                @image[2].draw(x + @pos.x + tmp_x * @tile_size * @scale.x, y + @pos.y * @scale.y, 0, @scale.x, @scale.y)
            else
                @image[1].draw(x + @pos.x + tmp_x * @tile_size * @scale.x, y + @pos.y * @scale.y, 0, @scale.x, @scale.y)
            end
        end
    end

    def to_s
        puts "ProgressBar<#{@rect.x}x#{@rect.y} | #{@rect.width}x#{@rect.height}>"
    end

end
