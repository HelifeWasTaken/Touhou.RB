class CreditState < Omega::State

    def load()
        @pos = 600
        @logo = Omega::Sprite.new("assets/textures/gui/logo.png")
        @logo.set_origin(0.5)
        @logo.x = Omega.width / 2
        @logo.y = Omega.height / 2 + @pos
        @dev = Omega::Text.new("Team:", $font)
        @mattis = Omega::Text.new("Dalleau Mattis", $font)
        @raph = Omega::Text.new("Turpin Raphaël", $font)
        @joke = Omega::Text.new("Le manque de sommeil", $font)
        @sprt = Omega::Text.new("Assets:", $font)
        @touhou = Omega::Text.new("Touhou Project & the open source community", $font)
        @license = Omega::Text.new("Licenses:", $font)
        @mit = Omega::Text.new("- MIT", $font)
        @gpl = Omega::Text.new("- GNU General Public Licence 3", $font)
        @thank = Omega::Text.new("Thank you for playing!", $font)
        @dev.scale = Omega::Vector2.new(1.5, 1.5)
        @sprt.scale = Omega::Vector2.new(1.5, 1.5)
        @license.scale = Omega::Vector2.new(1.5, 1.5)
        @thank.scale = Omega::Vector2.new(2, 2)

        @transition = Omega::FadeTransition.new(5, Omega::Color::copy(Omega::Color::BLACK)) { Omega.set_state(PlayState.new) }
        @transition.alpha = 0
        $musics["Credits"].play(true)
    end

    def update()
        if Omega.pressed(Gosu::KB_SPACE)
            @pos -= 5
        else
            @pos -= 1
        end
        @logo.y = Omega.height / 2 + @pos
    end

    def draw()
        @logo.draw
        @dev.draw_at_pos(Omega::Text::WindowPos::MIDDLE, 0, @pos + 250);
        @mattis.draw_at_pos(Omega::Text::WindowPos::MIDDLE, 0, @pos + 350);
        @raph.draw_at_pos(Omega::Text::WindowPos::MIDDLE, 0, @pos + 400);
        @joke.draw_at_pos(Omega::Text::WindowPos::MIDDLE, 0, @pos + 450);
        @sprt.draw_at_pos(Omega::Text::WindowPos::MIDDLE, 0, @pos + 700);
        @touhou.draw_at_pos(Omega::Text::WindowPos::MIDDLE, 0, @pos + 800);
        @license.draw_at_pos(Omega::Text::WindowPos::MIDDLE, 0, @pos + 1050);
        @mit.draw_at_pos(Omega::Text::WindowPos::MIDDLE, 0, @pos + 1150);
        @gpl.draw_at_pos(Omega::Text::WindowPos::MIDDLE, 0, @pos + 1200)
        # puts @pos
        if @pos >= -1400
            @thank.draw_at_pos(Omega::Text::WindowPos::MIDDLE, 0, @pos + 1400);
        else
            @thank.draw_at_pos(Omega::Text::WindowPos::MIDDLE, 0, 0);
        end
        if @pos <= -1900 and not Omega.is_transition?
            Omega.launch_transition(@transition)
        end
    end

end