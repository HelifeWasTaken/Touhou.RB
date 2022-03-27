$cirno_talk = "./assets/talk/cirno_talk.png"
$sakuya_talk = "./assets/talk/sakuya_talk.png"

class MenuState < Omega::State

    def load
        @timer = 0
        @handler = BossManager.new()
        @parallax = Omega::Parallax.new([Omega::Sprite.new("./assets/nebula2.png")])
        @parallax.set_scale(4)
       $player.position.x = 500
        $player.position.y = 800
    end

    def update
        @parallax.y += 2
        $player.update()
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
    end

    def draw
        $camera.draw do
            $player.draw
            @handler.draw
            @parallax.draw
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
