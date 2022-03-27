class PlayState < Omega::State

    def load_level
    end

    def load_sprites()
        @player = Player.new
    end

    def load_camera
        @camera = Omega::Camera.new
        @camera.scale = Omega::Vector2.new($scale, $scale)

        $camera = @camera
    end

    def load
        load_sprites()
        load_camera()
        @timer = 0
    end

    def update
    end

    def draw
        @camera.draw do
            @player.draw
        end
    end

end
