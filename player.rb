class Player < Omega::SpriteSheet

    def initialize
        super("assets/textures/character/player.png", 48, 48)
        @max_health = 20;
        @health = 20;
        @position.x = 10
        @position.y = 10
        @shooter = BladeStop.new(false)

        set_origin(0.5)
    end

    def controller
        if Omega::pressed(Gosu::KB_W)
            @position.y -= 10
        end
        if Omega::pressed(Gosu::KB_A)
            @position.x -= 10
        end
        if Omega::pressed(Gosu::KB_S)
            @position.y += 10
        end
        if Omega::pressed(Gosu::KB_D)
            @position.x += 10
        end
        if Omega::pressed(Gosu::KB_SPACE)
            @shooter.shoot(@position.x, @position.y)
        end
        if Omega::just_pressed(Gosu::KB_M)
            @shooter.level += 1
            if (@shooter.level == 5)
                @shooter.level = 0
            end
        end
    end

    def update
        if not $stop
            self.controller
            @shooter.update
        else
            @shooter.on_stop
        end
    end

    def draw
        @shooter.draw
        super
    end
end