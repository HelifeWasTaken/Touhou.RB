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
    module PState
      FIRST_LOAD = 0,
      FLASH = 1,
      NORMAL = 2
    end

    def load_sprites()
      @bg = Omega::Sprite.new("./assets/titlescreen_background.png")
      @bg.set_scale(2)

      @text = BlinkingText.new("Press Enter to Start")

      @pres = Omega::Text.new("Mattis and Raphaël present to you", $font)
      @pres.color = Omega::Color::WHITE
      @pres.alpha = 0
      @pres2 = Omega::Text.new("in occassion of the Epitech Jam", $font)
      @pres2.color = Omega::Color::WHITE
      @pres2.alpha = 0

      @logo = Omega::Sprite.new("assets/textures/gui/logo.png")
      @logo.scale.x = 1.5
      @logo.scale.y = 1.5
      @logo.set_origin(0.5)
      @logo.x = Omega.width / 2
      @logo.y = 250

      @state = PState::FIRST_LOAD
      @cardboard = Omega::Color::BLACK
      $musics["Main_menu"].play(true)
    end

    def load

        load_sprites()
        @timer = 0
    end

    def update
        if @state == PState::FIRST_LOAD
          @timer += 1
          if @timer >= 350 or Game.is_just_pressed_ok
            @cardboard = Omega::Color::WHITE
            @state = PState::FLASH
          end
          return
        end
        if @state == PState::FLASH
          @cardboard._alpha = (@cardboard.alpha - 5).clamp(0, 255)
          if @cardboard.alpha == 0
            @state = PState::NORMAL
          end
          return
        end
        if @state == PState::NORMAL
          @cardboard.alpha = 255
        end
        @text.update

        if (Game.is_just_pressed_ok and not Omega.is_transition?)
            transition = Omega::FadeTransition.new(10, Omega::Color::copy(Omega::Color::BLACK)) { Omega.set_state(MenuState.new) }
            Omega.launch_transition(transition)
            @text.speed *= 5
        end
    end

    def draw
      @bg.draw
        $camera.draw do
          @logo.draw
          @text.altdraw
          if not @state == PState::NORMAL
            Gosu.draw_rect(0, 0, Omega.width, Omega.height, @cardboard, 1)
          end
          if @state == PState::FIRST_LOAD and @timer > 100
            @pres.draw_at_pos(Omega::Text::WindowPos::MIDDLE, 0, -50);
            @pres.alpha += (255 - @pres.alpha) * 0.1
          end
          if @state == PState::FIRST_LOAD and @timer > 200
            @pres2.draw_at_pos(Omega::Text::WindowPos::MIDDLE, 0, 0);
            @pres2.alpha += (255 - @pres2.alpha) * 0.1
          end
        end
    end

end
