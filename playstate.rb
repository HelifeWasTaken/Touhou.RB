class PlayState < Omega::State

    def load_level
    end

    def load_sprites()
    end

    def load_icon()
    end

    def load_camera
        @camera = Omega::Camera.new
        @camera.scale = Omega::Vector2.new($scale, $scale)

        $camera = @camera
    end

    def load_ui
    end

    def load
        @timer = 0
    end

    def update
    end

    def draw
        @camera.draw do
        end
    end

end
