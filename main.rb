#!/bin/ruby
require_relative "./lib/omega"

forbidden_files = [
    "push_that.rb"
]

(Dir["*.rb"] + Dir["shooter/*.rb"]).each do |file|
    require_relative file if file != File.basename(__FILE__) and not forbidden_files.include?(file)
end

Gosu::enable_undocumented_retrofication

class Game < Omega::RenderWindow

    $font = Gosu::Font.new(35, name: "assets/SuperLegendBoy.ttf")

    $musics = {
        "Main_menu" => Gosu::Song.new("assets/musics/pied_menu.ogg"),
        "Simple_dialog" => Gosu::Song.new("assets/musics/simple_dialog.ogg"),
        "Confrontation" => Gosu::Song.new("assets/musics/confrontation.ogg"),
        "GameOver" => Gosu::Song.new("assets/musics/game_over.ogg"),
        "Credits" => Gosu::Song.new("assets/musics/credits.ogg"),
        "Cirno_phase1" => Gosu::Song.new("assets/musics/cirno1.ogg"),
        "Cirno_phase2" => Gosu::Song.new("assets/musics/cirno2.ogg"),
        "Faith" => Gosu::Song.new("assets/musics/faith.ogg"),
        "Death" => Gosu::Song.new("assets/musics/death.ogg"),
        "Last_run" => Gosu::Song.new("assets/musics/last_run.ogg")
    }

    $sounds = {
        "talk" => Gosu::Sample.new("assets/musics/talk.wav"),
        "shot" => Gosu::Sample.new("assets/sounds/shot.wav"),
        "collide" => Gosu::Sample.new("assets/sounds/collide.wav"),
        "explosion" => Gosu::Sample.new("assets/sounds/explosion.wav"),
        "lazor" => Gosu::Sample.new("assets/sounds/ultra_lazor.wav")
    }

    $maps = {

    }

    $enemy_bullets = []
    $player_bullets = []

    $scale = 1
    $camera = Omega::Camera.new()
    $camera.scale = Omega::Vector2.new($scale, $scale)

    $stop = false

    $in_cinematic = false

    $dummy = Omega::Vector2.new(500, 540)

    $player = nil

    $misc = []

    $actual_boss = 0

    $text_box = TextBoxHandler.new()

    $player_count = 1

    def load
        $game = self

        $camera = Omega::Camera.new($scale)
        transition = Omega::FadeTransition.new(5, Omega::Color::copy(Omega::Color::BLACK)) { Omega.set_state(PlayState.new) }
        transition.alpha = 255

        Omega.launch_transition(transition)
    end

    def Game.is_just_pressed_ok
        return (Omega::just_pressed(Gosu::KB_X) or Omega::just_pressed(Gosu::KB_RETURN) or Omega::just_pressed(Gosu::GP_0_BUTTON_0))
    end

end

Omega.run(Game, "config.json")
