class MenuState < Omega::State

    def load
        @player = Player.new
        @timer = 0
    end

    def update
        @player.update()
        if not $stop
            for bullet in $player_bullets
                bullet.go_f4st
            end
            for bullet in $enemy_bullets
                bullet.go_f4st
            end
        end
    end

    def draw
        $camera.draw do
            $player_bullets.each do |bullet|
                bullet.draw
            end
            $enemy_bullets.each do |bullet|
                bullet.draw
            end
            @player.draw
        end
    end

end
