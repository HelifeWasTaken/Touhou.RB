class MenuState < Omega::State

    def load
        @cirno = Cirno.new()
        @cirno.position.x = 500
        @cirno.position.y = 200
        @timer = 0
        $player.position.x = 500
        $player.position.y = 800
        @boss_bar = ProgressBar.new().max(@cirno.health_max[@cirno.phase]).value(5).color(0xff_fafafa).tile_size(16).display("assets/textures/gui/bar.png").size(60)
        @gui = GUI.new().add(@boss_bar).at(Omega.width / 2 - 30 * 16, 16)
    end

    def update
        $player.update()
        @cirno.update()
        @boss_bar.value(@cirno.health)
        @boss_bar.max(@cirno.health_max[@cirno.phase])
        collision()
        if not $stop
            for bullet in $player_bullets
                bullet.go_f4st
            end
            for bullet in $enemy_bullets
                bullet.go_f4st
            end
            for misc in $misc
                misc.update
            end
        end
    end

    def collision
        for bullet in $enemy_bullets
            if bullet.rect.collides?($player.box)
                $player.damage()
                bullet.on_hit()
            end
        end
        for bullet in $player_bullets
            if bullet.rect.collides?(@cirno.box)
                @cirno.damage(bullet.damage)
                bullet.on_hit
            end
        end
    end

    def draw
        $camera.draw do
            $player.draw
            @cirno.draw
            $player_bullets.each do |bullet|
                bullet.draw
            end
            $enemy_bullets.each do |bullet|
                bullet.draw
            end
            for misc in $misc
                misc.draw
            end
            @gui.draw
        end
    end

end
