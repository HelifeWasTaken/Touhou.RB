class BlinkingText < Omega::Text

    attr_accessor :speed

  def initialize(text)
    super(text, $font)

    @alpha_go_down = false
    @speed = 10
  end

  def update
    if @alpha_go_down == true
      if self.alpha <= 0
        @alpha_go_down = false
      else
        self.alpha=self.alpha - @speed
      end
    else
      if self.alpha >= 255
        @alpha_go_down = true
      else
        self.alpha=self.alpha + @speed
      end
    end
  end

  def altdraw
      draw_at_pos(Omega::Text::WindowPos::MIDDLE, 0, 0)
  end

end

class PlayState < Omega::State

    def load_level
    end

    def load_sprites()
      @bg = Omega::Sprite.new("./assets/titlescreen_background.png")
      @bg.set_scale(2)

      @text = BlinkingText.new("Press Enter to Start the game")
    end

    def load_camera

        @camera = Omega::Camera.new
        @camera.scale = Omega::Vector2.new($scale, $scale)
        $camera = @camera

    end

    def load

        load_camera
        load_sprites
        load_sprites()
        load_camera()
        @timer = 0
    end

    def update
        @timer += 1
        @text.update

        # puts "Game: " + Game.is_just_pressed_ok.to_s + " is_transition: " + Omega.is_transition?.to_s
        if (Game.is_just_pressed_ok and not Omega.is_transition?)
            transition = Omega::FadeTransition.new(10, Omega::Color::copy(Omega::Color::BLACK)) { Omega.set_state(MenuState.new) }
            Omega.launch_transition(transition)
        end
    end

    def draw
        @camera.draw do
          @text.altdraw
        end
        @bg.draw
    end

end
