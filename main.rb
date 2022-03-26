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

    $event_messages = [
    ]

    $scale = 3.0
    $camera = nil

    $wave_manager = WaveManager.new()
    $player = nil

    def load
        $game = self

        Game.load_parallax($c_planet, true)
        transition = Omega::FadeTransition.new(5, Omega::Color::copy(Omega::Color::BLACK)) { Omega.set_state(MenuState.new) }
        transition.alpha = 255

        $player = Spaceship.new()

        Omega.launch_transition(transition)
    end

    def Game.is_just_pressed_ok
        return (Omega::just_pressed(Gosu::KB_X) or Omega::just_pressed(Gosu::KB_RETURN) or Omega::just_pressed(Gosu::GP_0_BUTTON_0))
    end

end

Omega.run(Game, "config.json")
