class MenuState < Omega::State

    def load
        @timer = 0

        @handler = BossManager.new()
        @parallax = Omega::Parallax.new([Omega::Sprite.new("./assets/nebula2.png")])
        @parallax.set_scale(4)
    end

    def update
        @handler.update
        $player.update
        @parallax.y += 2
    end

    def draw
        $camera.draw do
            $player.draw
            @handler.draw
            @parallax.draw
        end
    end

end
