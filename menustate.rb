class MenuState < Omega::State

    def load
        @timer = 0

        @parallax = Omega::Parallax.new([Omega::Sprite.new("./assets/nebula2.png")])
        @parallax.set_scale(4)
    end

    def update
        @parallax.y += 2
    end

    def draw
        $camera.draw do
          @parallax.draw
        end
    end

end
