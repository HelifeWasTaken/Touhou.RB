module Omega

    def Omega.draw_fps(scale = 0.3, z = 1000)
        Omega::Font.draw_text("FPS : #{Gosu.fps}", 2, 2, z, 0.3, 0.3)
    end

    def Omega.fps
        return Gosu.fps
    end

    def Omega.distance(vec1, vec2)
        return Gosu.distance(vec1.x, vec1.y, vec2.x, vec2.y)
    end

    def Omega.distance_squared(vec1, vec2)
        return (vec2.x - vec1.x)**2 + (vec2.y - vec1.y)**2
    end

    def Omega.draw_progress_bar(x, y, z, width, height, backcolor, frontcolor, current, max, border = 2)
        final_width = 0
        final_width = (width.to_f/max) * current if max != 0
        Gosu.draw_rect(x, y, width, height, backcolor, z)
        Gosu.draw_rect(x+border, y+border, final_width-border*2, height-border*2, frontcolor, z) if final_width > 0
    end

    def Omega.to_rad(angle)
        return (angle * Math::PI/180)
    end

    def Omega.sign(number)
        if number > 0
            return 1
        elsif number < 0
            return -1
        end
        return 0
    end

end