class GameOverState < Omega::State

    def load()
        if $actual_boss == 0
            $text_box = TextBoxHandler.new()
            $text_box.set_left_character($cirno_talk)
            $text_box.set_right_character($sakuya_talk)
            $text_box.add_text("Duh! I'm an ice fairy!", true)
            $text_box.add_text(". . .", false)
            $text_box.start()
        end
        if $actual_boss == 1
            $text_box = TextBoxHandler.new()
            $text_box.set_right_character($sakuya_talk)
            $text_box.add_text("It seems that you couldn't handle the cold", true)
            $text_box.add_text(". . .", false)
            $text_box.start()
        end

        @transition = Omega::FadeTransition.new(5, Omega::Color::copy(Omega::Color::BLACK)) { Omega.set_state(PlayState.new) }
        @transition.alpha = 0
        $musics["GameOver"].play(true)
        @text = Omega::Text.new("Game Over", $font)
        @text.alpha = 0
        @state = 0
    end

    def update()
        if @state == 0
            $text_box.update
            if $text_box.finished
                @state = 1
            end
        end
        if @state > 0
            @text.alpha += 5
            if @text.alpha >= 128
                @state = 2
            end
        end
        if @state == 2 and Game.is_just_pressed_ok and not Omega.is_transition?
            Omega.launch_transition(@transition)
        end
    end

    def draw()
        if @state == 0
            $text_box.draw
        else
            @text.draw_at_pos(Omega::Text::WindowPos::MIDDLE, 0, 0)
        end
    end

end