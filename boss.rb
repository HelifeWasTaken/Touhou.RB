require_relative "player.rb"

module Spell
    RED = Omega::Color::RED
    MAGENTA = Omega::Color::FUCHSIA
    BLUE = Omega::Color::BLUE
    CYAN = Omega::Color::CYAN
    GREEN = Omega::Color::GREEN
    YELLOW = Omega::Color::YELLOW
    WHITE = Omega::Color::WHITE
end

class Boss < TouhouCharacter

    attr_accessor :health_max, :health, :phase, :dead, :timer

    def initialize(sprite, max_frames, scale, size, health, phases, env)
        super(sprite, max_frames, scale, size, size)
        @phase = 0
        @health_max = health
        @health = @health_max[0]
        @main = Omega::Sprite.new("assets/textures/misc/main_spell.png")
        @main.set_origin(0.5)
        @second
        @cast = false
        @cast_color = Omega::Color::WHITE
        @env = env
        @dead = false
        @behaviours = []
        @probs = []
        @sleep = 0
        @star = Star.new()
        @timer = 0
        @finished = false
    end

    def draw
        @env.draw
        @main.draw
        super
    end

    def cast
        @main.color = @cast_color
        @main.alpha += (255 - @main.alpha) * 0.1
        @main.scale.x += (1 - @main.scale.x) * 0.1
        @main.scale.y += (1 - @main.scale.y) * 0.1
    end

    def uncast
        @main.alpha += (0 - @main.alpha) * 0.1
        @main.scale.x += (10 - @main.scale.x) * 0.1
        @main.scale.y += (10 - @main.scale.y) * 0.1
    end

    def choose
        sum = @probs[@phase].sum
        tmp = 0.0
        ran = rand(0.0..sum)

        for i in 0...@probs[@phase].size
            tmp += @probs[@phase][i]
            if ran <= tmp
                return i
            end
        end
    end

    def update
        if not @dead
            @env.update
        end
        if @dead
            @main.angle += 10
        else
            @main.angle += 5
        end
        @main.position.x = self.position.x
        @main.position.y = self.position.y
        @main.color = @cast_color
        if @cast
            cast()
        else
            uncast()
        end
        if @dead
            return
        end
        if @sleep >= 0.0
            @sleep -= 1.0 / 60.0
            if @sleep <= 0.0
                @behaviours[@phase][@type].reset
                @type = self.choose()
                @behaviours[@phase][@type].reset
            end
        end
        self.behaviour
        super
    end

    def clear_bullet
        while $enemy_bullets.size > 0
            $enemy_bullets[0].clear
        end
        while $player_bullets.size > 0
            $player_bullets[0].clear
        end
    end

    def phase_up
        @phase += 1
        @health = @health_max[@phase]
    end

    def dead_anim
        puts @timer
        if @timer >= 0.0
            @timer -= 1.0 / 60.0
        end
        if @timer <= 0.0
            $in_cinematic = false
            @finished = true
        end
        @cast_color = Omega::Color::RED
        @behaviours[@phase][@type].reset
        @star.emit_at(@position.x, @position.y)
        $in_cinematic = true
        if not Omega.in_range(@position, Omega::Vector2.new(500, 200), 20)
            @position.x += (500 - @position.x) * 0.05
            @position.y += (200 - @position.y) * 0.05
        end
        if not Omega.in_range($player.position, Omega::Vector2.new(500, 800), 20)
            $player.position.x += (500 - $player.position.x) * 0.05
            $player.position.y += (800 - $player.position.y) * 0.05
        end
    end

    def finished?
        return @finished
    end

    def damage(dmg)
        @health -= dmg
    end

    def is_dead?
        @health <= 0.0
    end

    def has_more_phases?
        return @phase < @health_max.size - 1
    end

    def behaviour; end

end

class Cirno < Boss

    def initialize()
        super("assets/textures/character/cirno.png", 2, 1.5, 64, [1, 1], 2, IceBiome.new())
        @sleep = 0
        @phase = 0
        @type = 0
        @behaviours = [
            [
                Cirno1.new(self),
                Cirno2.new(self),
                Cirno3.new(self),
                Cirno4.new(self)
            ],
            [
                Cirno1.new(self),
                Cirno2.new(self),
                Cirno3.new(self),
                Cirno4.new(self)
            ]
        ]
        @probs = [
            [
                0.5,
                0.1,
                0.1,
                0.3
            ],
            [
                0.3,
                0.2,
                0.2,
                0.3
            ]
        ]
    end

    def draw
        super
    end

    def choose
        sum = @probs[@phase].sum
        tmp = 0.0
        ran = rand(0.0..sum)

        for i in 0...@probs[@phase].size
            tmp += @probs[@phase][i]
            if ran <= tmp
                return i
            end
        end
    end

    def update
        super
    end

    def behaviour
        if @sleep > 0.0
            return;
        end
        if not @behaviours[@phase][@type].has_init?
            @behaviours[@phase][@type].init
            @cast = true
            @cast_color = @behaviours[@phase][@type].color
        elsif not @behaviours[@phase][@type].has_end?
            @behaviours[@phase][@type].behave
        else
            if @sleep <= 0.0
                @cast = false
                @sleep = @behaviours[@phase][@type].sleep
            end
        end
    end

end

class BossManager

    def initialize()

        @text_box = TextBoxHandler.new()
        @events = [
            [
                lambda {
                    @text_box = TextBoxHandler.new()
                    @text_box.set_left_character($cirno_talk)
                    @text_box.set_right_character($sakuya_talk)
                    @text_box.add_text("I'm gony kick your assets", true)
                    @text_box.add_text("Your trigered my trap card", false)
                    @text_box.add_text("And i negate your effect with Ash Blossom", true)
                    @text_box.add_text("NOoooooooooooooo", false)
                    @text_box.start()
                },
                lambda {
                    @text_box = TextBoxHandler.new()
                    @text_box.set_left_character($cirno_talk)
                    @text_box.set_right_character($sakuya_talk)
                    @text_box.add_text("This is the last time we talk", true)
                    @text_box.add_text("Your trigered my trap card", false)
                    @text_box.add_text("And i negate your effect with Ash Blossom", true)
                    @text_box.add_text("NOoooooooooooooo", false)
                    @text_box.start()
                }
            ]
        ]
        @bosses = [
            Cirno.new()
        ]
        @actual_boss = 0
        @in_last_text = false
        @bar = ProgressBar.new().max(@bosses[@actual_boss].health_max[@bosses[@actual_boss].phase]).value(5).color(0xff_fafafa).tile_size(16).display("assets/textures/gui/bar.png").size(60)
    end

    def finished?
        return @actual_boss >= @bosses.size
    end

    def update_current_boss
        if @bosses[@actual_boss].finished?
            if @in_last_text
                if @text_box.finished
                    @actual_boss += 1
                    @in_last_text = 0
                end
                return
            end
            @events[@actual_boss][-1].call
            @in_last_text = true
            return
        else
            if not @text_box.finished
                $in_cinematic = true
                return
            end
            $in_cinematic = false
            @bosses[@actual_boss].update
            if @bosses[@actual_boss].dead
                @bosses[@actual_boss].dead_anim()
                return
            end
            if @bosses[@actual_boss].is_dead?
                @bosses[@actual_boss].clear_bullet()
                if @bosses[@actual_boss].has_more_phases?
                    @events[@actual_boss][@bosses[@actual_boss].phase].call
                    @bosses[@actual_boss].phase_up
                else
                    @bosses[@actual_boss].dead = true
                    @bosses[@actual_boss].timer = 1
                end
            end
        end
    end

    def update()
        if finished?
            return
        end
        @text_box.update
        @bar.value(@bosses[@actual_boss].health)
        @bar.max(@bosses[@actual_boss].health_max[@bosses[@actual_boss].phase])
        update_current_boss()
    end

    def draw()
        if finished?
            return
        end
        if not @bosses[@actual_boss].finished?
            @bosses[@actual_boss].draw
        end
        @bar.draw(Omega.width / 2 - 30 * 16, 16)
        @text_box.draw
    end

    def damage()
        if finished?
            return
        end
        for bullet in $player_bullets
            if bullet.rect.collides?(@bosses[@actual_boss].box)
                @bosses[@actual_boss].damage(bullet.damage)
            end
        end
    end

end

class Environnement

    def initialize(bg)
        @bg = bg
    end

    def update; end

    def draw; end

end

class IceBiome < Environnement

    def initialize()
        super(nil)
        @timer = 0
    end

    def update
        if @timer <= 0.0
            snow = SnowFlake.new(true)
            snow.add_bullet_at(rand(10..990), -10)
            @timer = 0.5
        end
        if @timer >= 0.0
            @timer -= 1.0 / 60.0
        end
    end

    def draw; end

end

class Behaviour

    attr_accessor :sleep, :color

    def initialize(entity)
        @entity = entity
        @inited = false
        @ended = false
        @sleep = 0
        @color = Spell::WHITE
    end

    def reset
        @inited = false
        @ended = false
    end

    def init; end

    def behave; end

    def has_init?; end

    def has_end?; end

end

class Cirno1 < Behaviour

    def initialize(entity)
        super(entity)
        @bullet = Pellet.new(true, Bullet::Variant::CYAN)
        @pos = nil
        @sleep = 0.5
        @color = Spell::CYAN
    end

    def reset
        @pos = nil
        super
    end

    def init
        @pos ||= Omega::Vector2.new(rand(100..900), rand(100..400))
        @entity.position.x += (@pos.x - @entity.position.x) * 0.05
        @entity.position.y += (@pos.y - @entity.position.y) * 0.05
        if Omega.in_range(@entity.position, @pos, 20)
            @inited = true
        end
    end

    def aim(origin)
        return Math::atan2($player.position.y - origin.y, $player.position.x - origin.x) * 180.0 / Math::PI
    end

    def behave
        angle = aim(@entity.position)
        @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, angle + 40, Bullet::Variant::CYAN)
        @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, angle + 20, Bullet::Variant::CYAN)
        @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, angle, Bullet::Variant::CYAN)
        @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, angle - 20, Bullet::Variant::CYAN)
        @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, angle - 40, Bullet::Variant::CYAN)
        if @entity.phase == 1
            @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, angle + 30, Bullet::Variant::CYAN)
            @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, angle - 30, Bullet::Variant::CYAN)
            @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, angle + 10, Bullet::Variant::CYAN)
            @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, angle - 10, Bullet::Variant::CYAN)
        end
        @ended = true
    end

    def has_init?
        return @inited
    end

    def has_end?
        return @ended
    end

end

class Cirno2 < Behaviour

    def initialize(entity)
        super(entity)
        @index = 1
        @bullet = SplitBoi.new(true, Bullet::Variant::CYAN)
        @sleep = 1
        @color = Spell::CYAN
    end

    def reset
        @index = 1
        super
    end

    def init
        @entity.position.x += (200 - @entity.position.x) * 0.05
        @entity.position.y += (200 - @entity.position.y) * 0.05
        if Omega.in_range(@entity.position, Omega::Vector2.new(200, 200), 10)
            @inited = true
        end
    end

    def behave
        @entity.position.x += (800 - @entity.position.x) * 0.05
        if Omega.in_range(@entity.position, Omega::Vector2.new(200 + (@index * 100), 200), 10) and @index < 6
            @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, 90 + (20 + -10 * @index), Bullet::Variant::CYAN)
            @index += 1
        end
        if Omega.in_range(@entity.position, Omega::Vector2.new(800, 200), 10)
            @ended = true
        end
    end

    def has_init?
        return @inited
    end

    def has_end?
        return @ended
    end

end

class Cirno3 < Behaviour

    def initialize(entity)
        super(entity)
        @bullet = Pellet.new(true, Bullet::Variant::CYAN)
        @shot = 45
        @angle = 0
        @cd = 0
        @sleep = 2
        @color = Spell::CYAN
    end

    def reset
        @shot = 50
        @angle = 0
        @cd = 0.0
        super
    end

    def init
        @entity.position.x += (500 - @entity.position.x) * 0.05
        @entity.position.y += (200 - @entity.position.y) * 0.05
        if Omega.in_range(@entity.position, Omega::Vector2.new(500, 200), 20)
            @inited = true
        end
    end

    def behave
        if @cd <= 0.0 && @shot > 0
            @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, @angle - 5, Bullet::Variant::CYAN)
            @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, @angle, Bullet::Variant::CYAN)
            @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, @angle + 5, Bullet::Variant::CYAN)
            @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, @angle + 85, Bullet::Variant::CYAN)
            @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, @angle + 90, Bullet::Variant::CYAN)
            @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, @angle + 95, Bullet::Variant::CYAN)
            @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, @angle + 175, Bullet::Variant::CYAN)
            @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, @angle + 180, Bullet::Variant::CYAN)
            @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, @angle + 185, Bullet::Variant::CYAN)
            @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, @angle + 265, Bullet::Variant::CYAN)
            @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, @angle + 270, Bullet::Variant::CYAN)
            @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, @angle + 275, Bullet::Variant::CYAN)
            @angle += 4
            @shot -= 1
            @cd = 0.1
        else
            if @shot == 0
                @ended = true
            else
                if @cd > 0.0
                    @cd -= 1.0 / 60.0
                end
            end
        end
    end

    def has_init?
        return @inited
    end

    def has_end?
        return @ended
    end

end

class Cirno4 < Behaviour

    def initialize(entity)
        super(entity)
        @bullet = Pellet.new(true, Bullet::Variant::GREEN)
        @pos = nil
        @sleep = 0.5
        @tmp = []
        @cycle = 0
        @timer = 0
        @speed = 0.5
        @delta = 1
        @color = Spell::GREEN
    end

    def reset
        @pos = nil
        @cycle = 0
        @speed = 0.5
        @delta = 1
        @tmp = []
        super
    end

    def init
        @pos ||= Omega::Vector2.new(rand(100..900), rand(100..400))
        @entity.position.x += (@pos.x - @entity.position.x) * 0.05
        @entity.position.y += (@pos.y - @entity.position.y) * 0.05
        if Omega.in_range(@entity.position, @pos, 20)
            @inited = true
        end
    end

    def aim(origin)
        return Math::atan2($player.position.y - origin.y, $player.position.x - origin.x) * 180.0 / Math::PI
    end

    def behave
        if @tmp.size == 0
            for i in 0..8
                @tmp << @bullet.copy_at(@entity.position.x, @entity.position.y)
                @tmp[-1].angle = @cycle + 90
                @tmp[-1].add_bullet(@tmp[-1])
                @cycle += 45
            end
        end
        if @delta < 50
            for i in 0..8
                @tmp[i].position.x = @entity.position.x + @delta * Math::cos(Omega::to_rad(@cycle))
                @tmp[i].position.y = @entity.position.y + @delta * Math::sin(Omega::to_rad(@cycle))
                @tmp[i].angle = @cycle + 90
                @cycle += 45
            end
            @cycle += @speed
            @speed += 0.1
            @delta += 0.5
            return
        end
        tmp = Circle.new(true)
        tmp.position.x = @entity.position.x
        tmp.position.y = @entity.position.y
        tmp.angle = aim(@entity.position)
        for p in @tmp
            tmp.pellet << p
        end
        tmp.add_bullet(tmp)
        @ended = true
    end

    def has_init?
        return @inited
    end

    def has_end?
        return @ended
    end

end
