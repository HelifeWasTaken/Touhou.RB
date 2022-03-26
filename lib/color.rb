module Omega

    class Color < Gosu::Color

        # Original Gosu colors (note : CYAN == AQUA)
        NONE = Omega::Color.new(0x00_000000)
        BLACK = Omega::Color.new(0xff_000000)
        GRAY = Omega::Color.new(0xff_808080)
        WHITE = Omega::Color.new(0xff_ffffff)
        AQUA = Omega::Color.new(0xff_00ffff)
        RED = Omega::Color.new(0xff_ff0000)
        GREEN = Omega::Color.new(0xff_00ff00)
        BLUE = Omega::Color.new(0xff_0000ff)
        YELLOW = Omega::Color.new(0xff_ffff00)
        FUCHSIA = Omega::Color.new(0xff_ff00ff)
        CYAN = Omega::Color.new(0xff_00ffff)

        # New colors
        ORANGE = Omega::Color.new(0xff_ff8000)

        def _alpha=(a)
            initialize(a.clamp(0, 255), self.red, self.green, self.blue)
        end

        def red=(r)
            initialize(self.alpha, r.clamp(0, 255), self.green, self.blue)
        end

        def green=(g)
            initialize(self.alpha, self.red, g.clamp(0, 255), self.blue)
        end

        def blue=(b)
            initialize(self.alpha, self.red, self.green, b.clamp(0, 255))
        end

        def color_string
            return "alpha:#{self.alpha}, red:#{self.red}, green:#{self.green}, blue:#{self.blue}"
        end

        def self.copy(color)
            ncolor = Omega::Color.new(color.alpha, color.red, color.green, color.blue)
        end
    end

end