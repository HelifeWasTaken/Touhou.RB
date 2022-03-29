$cirno_talk = "./assets/talk/cirno_talk.png"
$sakuya_talk = "./assets/talk/sakuya_talk.png"
$shion_talk = "./assets/talk/talk_shion.png"

class MenuState < Omega::State

    def boss_load
        @handler.load(Cirno.new, [
            $musics["Cirno_phase1"],
            $musics["Cirno_phase2"]
            ], [
            lambda {
                $text_box = TextBoxHandler.new()
                $text_box.set_left_character($cirno_talk)
                $text_box.set_right_character($sakuya_talk)
                $text_box.add_text("I'm Cirno. The Eternal omiwatari!", true)
                $text_box.add_text("...", false)
                $text_box.add_text("Answer me you idiot! You don't know how powerful i'm really am!", true)
                $text_box.add_text("!!", false)
                $text_box.start()
            },
            lambda {
                $text_box = TextBoxHandler.new()
                $text_box.set_left_character($cirno_talk)
                $text_box.set_right_character($sakuya_talk)
                $text_box.add_text("I'm the strongest fairy! I cannot be defeated by a weakling like you!", true)
                $text_box.add_text("...", false)
                $text_box.add_text("As a fairy, i'm part of nature. I will be back!", true)
                $text_box.add_text(". . .", false)
                $text_box.start()
            }
        ],
        lambda {
            $text_box = TextBoxHandler.new()
                $text_box.set_left_character($cirno_talk)
                $text_box.set_right_character($sakuya_talk)
                $text_box.add_text("Give me back my blueberry pie!!!", true)
                $text_box.add_text(".....", false)
                $text_box.add_text("I'm stronger than you'll ever be!", true)
                $text_box.add_text("...!", false)
                $text_box.start()
                $musics["Simple_dialog"].play(true)
        })
        @handler.load(Whiterock.new, [
            $musics["Faith"],
            $musics["Death"],
            $musics["Last_run"]
            ], [
            lambda {
                $text_box = TextBoxHandler.new()
                $text_box.set_right_character($sakuya_talk)
                $text_box.set_left_character($shion_talk)
                $text_box.add_text("I didn't expect you to be that strong", true)
                $text_box.add_text("...", false)
                $text_box.add_text("Let's see if you can handle this!", true)
                $text_box.start()
            },
            lambda {
                $text_box = TextBoxHandler.new()
                $text_box.set_right_character($sakuya_talk)
                $text_box.set_left_character($shion_talk)
                $text_box.add_text("Still alive I see", true)
                $text_box.add_text("...", false)
                $text_box.add_text("Then let's speed up th pace, shall we?", true)
                $text_box.add_text(". . .", false)
                $text_box.add_text("Embrace yourself!!", true)
                $text_box.start()
            },
            lambda {
                $text_box = TextBoxHandler.new()
                $text_box.set_right_character($sakuya_talk)
                $text_box.set_left_character($shion_talk)
                $text_box.add_text("I guess i overestimated your strength...", true)
                $text_box.add_text("...", false)
                $text_box.add_text("I will have my revenge someday...", true)
                $text_box.add_text(". . .", false)
                $text_box.start()
            }
        ],
        lambda {
            $text_box = TextBoxHandler.new()
                $text_box.set_right_character($sakuya_talk)
                $text_box.set_left_character($shion_talk)
                $text_box.add_text("*You feel a strong presence*", false)
                $text_box.add_text("You seem pretty strong, little one", true)
                $text_box.add_text("Let's see how far can you go", true)
                $text_box.add_text("!!!", false)
                $text_box.start()
                $musics["Confrontation"].play(true)
        })
    end

    def load
        $player = PlayerHandler.new($player_count)
        @timer = 0
        @handler = BossManager.new()
        @parallax = Omega::Parallax.new([Omega::Sprite.new("./assets/nebula2.png")])
        @parallax.set_scale(4)
        $player.set_pos(500, 800)
        $player.health = $player.max_health
        $enemy_bullets.clear()
        $player_bullets.clear()

        @bar = ProgressBar.new().max($player.max_health).value($player.health).color(0xff_fa0000).tile_size(16).display("assets/textures/gui/bar.png").size(30)

        @transition = Omega::FadeTransition.new(5, Omega::Color::copy(Omega::Color::BLACK)) { Omega.set_state(CreditState.new) }
        @transition.alpha = 0
        @gtransition = Omega::FadeTransition.new(5, Omega::Color::copy(Omega::Color::BLACK)) { Omega.set_state(GameOverState.new) }
        @gtransition.alpha = 0
        boss_load()
        @handler.update()
    end

    def update
        $actual_boss = @handler.actual_boss

        @bar.max($player.max_health)
        @bar.value($player.health)

        @parallax.y += 2
        $player.update()
        @handler.update()
        if @handler.finished?
            if not Omega.is_transition?
                Omega.launch_transition(@transition)
            end
            return
        end
        if $player.is_dead?
            if not Omega.is_transition?
                Omega.launch_transition(@gtransition)
            end
            return
        end
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
            if $player.collides?(bullet.rect)
                $player.damage()
                bullet.on_hit()
            end
        end
        @handler.damage
    end

    def draw
        $camera.draw do
            @parallax.draw
            $player.draw
            @handler.draw
            @bar.draw(Omega.width / 2 - 15 * 16, Omega.height - 64)
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
