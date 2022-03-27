$cirno_talk = "./assets/talk/cirno_talk.png"
$sakuya_talk = "./assets/talk/sakuya_talk.png"

class MenuState < Omega::State

    def load
        # @cirno = Cirno.new()
        # @cirno.position.x = 500
        # @cirno.position.y = 200
        @handler = BossManager.new
        @timer = 0
        $player.position.x = 500
        $player.position.y = 800
    end

    def update
        $player.update()
        # @cirno.update()
        @handler.update()
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
        @handler.damage
        # for bullet in $player_bullets
        #     if bullet.rect.collides?(@cirno.box)
        #         @cirno.damage(bullet.damage)
        #         bullet.on_hit
        #     end
        # end
    end

    def draw
        $camera.draw do
            $player.draw
            # @cirno.draw
            @handler.draw
            $player_bullets.each do |bullet|
                bullet.draw
            end
            $enemy_bullets.each do |bullet|
                bullet.draw
            end
            for misc in $misc
                misc.draw
            end
        end
    end

end
