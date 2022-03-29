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
          super(sprite, max_frames, scale, size, size, Gosu::KB_A, Gosu::KB_D)
          @phase = 0
          @health_max = health
          @health = @health_max[0]
          @main = Omega::Sprite.new("assets/textures/misc/main_spell.png")
          @main.set_origin(0.5)
          @second = Omega::Sprite.new("assets/textures/misc/second_spell.png")
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

          @main.scale = Omega::Vector2.new(10, 10)
          @main.alpha = 0
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
          if not @dead and not $stop
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
          # for b in @behaviours[@phase]
          #     b.cooldown
          # end
          # if @behaviours[@phase][@type].has_end?
          #     if @behaviours[@phase][@type].can_init?
          #         @behaviours[@phase][@type].reset
          #     end
          #     @type = rand(0...@behaviours[@phase].size)
          #     if @behaviours[@phase][@type].can_init?
          #         @behaviours[@phase][@type].reset
          #     end
          # end
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
          @env.level_up
          $player.reset_health
      end

      def dead_anim
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
        for i in 0...$player_count
            pos = $player.get_position_of_player(i)
            if not Omega.in_range(pos, Omega::Vector2.new(500, 800), 20)
                pos.x += (500 - pos.x) * 0.05
                pos.y += (800 - pos.y) * 0.05
                $player.set_pos(pos.x, pos.y, i)
            end
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

    def behaviour
        # puts @behaviours[@phase][@type].behaviour_cd
        # puts @behaviours[@phase][@type].can_init?
        # # while (1); end
        # if not @behaviours[@phase][@type].can_init?
        #     @type = rand(0...@behaviours[@phase])
        #     return
        # end
        # # @behaviours[@phase][@type].reset
        # if not @behaviours[@phase][@type].has_init?
        #     @behaviours[@phase][@type].init
        #     @cast = true
        #     @cast_color = @behaviours[@phase][@type].color
        #     puts "jotourt"
        # elsif not @behaviours[@phase][@type].has_end?
        #     @behaviours[@phase][@type].behave
        #     puts "ufhrhur"
        # else
        #     @cast = false
        #     @behaviours[@phase][@type].behaviour_cd = @behaviours[@phase][@type].behaviour_cd_max / (@phase + 1)
        #     # @behaviours[@phase][@type].reset
        #     puts "gioioto"
        #     while true; end
        # end
    end

end

class Cirno < Boss

    def initialize()
        super("assets/textures/character/cirno.png", 2, 1.5, 64, [100, 150], 2, IceBiome.new())
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
                Cirno4.new(self),
                Cirno6.new(self),
                Cirno7.new(self)
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
                0.1,
                0.1,
                0.2,
                0.25,
                0.3,
                0.05
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
                @sleep = @behaviours[@phase][@type].behaviour_cd_max / (@phase + 1)
            end
        end
    end

end

class BossManager

    attr_accessor :actual_boss

    def initialize()

        @musics = []
        @startup = []
        @events = []
        @bosses = []
        @actual_boss = 0
        @in_last_text = false
        @bar = ProgressBar.new().color(0xff_fafafa).tile_size(16).display("assets/textures/gui/bar.png").size(50)
        @started = false
    end

    def load(boss, music, event, startup)
        @bosses << boss
        @events << event
        @startup << startup
        @musics << music
    end

    def finished?
        return @actual_boss >= @bosses.size
    end

    def next_boss
        @actual_boss += 1
    end

    def update_current_boss
        if not @started
            @started = true
            if not @startup[@actual_boss].nil?
                @startup[@actual_boss].call
                @bosses[@actual_boss].position.x = 500
                @bosses[@actual_boss].position.y = 200
            end
            return
        end
        if @bosses[@actual_boss].finished?
            if @in_last_text
                if $text_box.finished
                    @musics[@actual_boss][@bosses[@actual_boss].phase].volume = 0.5
                    @musics[@actual_boss][@bosses[@actual_boss].phase].stop
                    @actual_boss += 1
                    @in_last_text = 0
                    @started = false
                end
                return
            end
            @events[@actual_boss][-1].call
            @in_last_text = true
            return
        else
            if not $text_box.finished
                $in_cinematic = true
                return
            end
            $in_cinematic = false
            if @started
                @musics[@actual_boss][@bosses[@actual_boss].phase].play(true)
            end
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
                    $musics["Confrontation"].play(true)
                else
                    @bosses[@actual_boss].dead = true
                    @bosses[@actual_boss].timer = 3
                end
            end
        end
    end

    def update()
        if finished?
            return
        end
        $text_box.update
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
        @bar.draw(Omega.width / 2 - 25 * 16, 64)
        $text_box.draw
    end

    def damage()
        if finished?
            return
        end
        for bullet in $player_bullets
            if bullet.rect.collides?(@bosses[@actual_boss].box)
                @bosses[@actual_boss].damage(bullet.damage)
                bullet.on_hit
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
        @level = 0
    end

    def update
        if @timer <= 0.0
            snow = SnowFlake.new(true)
            for i in 0..@level
                snow.add_bullet_at(rand(10..990), -10)
            end
            @timer = 0.5 / (@level + 1)
        end
        if @timer >= 0.0
            @timer -= 1.0 / 60.0
        end
    end

    def level_up
        @level += 1
    end

    def draw; end

end

class Behaviour

    attr_accessor :sleep, :color, :behaviour_cd, :behaviour_cd_max

    def initialize(entity)
        @entity = entity
        @inited = false
        @ended = false
        @behaviour_cd = 0
        @behaviour_cd_max = 0
        @color = Spell::WHITE
        # @sleep = 0
    end

    def reset
        @inited = false
        @ended = false
    end

    def init; end

    def cooldown
        if @behaviour_cd > 0.0
            @behaviour_cd -= 1.0 / 60.0
        end
    end

    def behave; end

    def can_init?;
        @behaviour_cd <= 0.0
    end

    def has_init?; end

    def has_end?; end

end

class Cirno1 < Behaviour

    def initialize(entity)
        super(entity)
        @bullet = Pellet.new(true, Bullet::Variant::CYAN)
        @pos = nil
        @behaviour_cd_max = 0.5
        @color = Spell::CYAN
    end

    def reset
        @pos = nil
        super
    end

    def init
        @pos ||= Omega::Vector2.new(rand(100..900), rand(100..400))
        @entity.position.x += (@pos.x - @entity.position.x) * 0.05 * (@entity.phase + 1)
        @entity.position.y += (@pos.y - @entity.position.y) * 0.05 * (@entity.phase + 1)
        if Omega.in_range(@entity.position, @pos, 20)
            @inited = true
        end
    end

    def aim(origin)
        player = $player.get_random_player
        pos = $player.get_position_of_player(player)
        return Math::atan2(pos.y - origin.y, pos.x - origin.x) * 180.0 / Math::PI
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
        @behaviour_cd_max = 1
        @color = Spell::CYAN
    end

    def reset
        @index = 1
        super
    end

    def init
        @entity.position.x += (200 - @entity.position.x) * 0.05 * (@entity.phase + 1)
        @entity.position.y += (200 - @entity.position.y) * 0.05 * (@entity.phase + 1)
        if Omega.in_range(@entity.position, Omega::Vector2.new(200, 200), 10)
            @inited = true
        end
    end

    def behave
        @entity.position.x += (800 - @entity.position.x) * 0.05 * (@entity.phase + 1)
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
        @behaviour_cd_max = 2
        @color = Spell::CYAN
    end

    def reset
        @shot = 50
        @angle = 0
        @cd = 0.0
        super
    end

    def init
        @entity.position.x += (500 - @entity.position.x) * 0.05 * (@entity.phase + 1)
        @entity.position.y += (200 - @entity.position.y) * 0.05 * (@entity.phase + 1)
        if Omega.in_range(@entity.position, Omega::Vector2.new(500, 200), 20)
            @inited = true
        end
        super
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
            @cd = 0.1 / (@entity.phase + 1)
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
        @behaviour_cd_max = 0.5
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
        @entity.position.x += (@pos.x - @entity.position.x) * 0.05 * (@entity.phase + 1)
        @entity.position.y += (@pos.y - @entity.position.y) * 0.05 * (@entity.phase + 1)
        if Omega.in_range(@entity.position, @pos, 20)
            @inited = true
        end
    end

    def aim(origin)
        position = $player.get_position_of_player($player.get_random_player)
        return Math::atan2(position.y - origin.y, position.x - origin.x) * 180.0 / Math::PI
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
            @speed += 0.1 * (@entity.phase + 1)
            @delta += 0.5 * (@entity.phase + 1)
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

class Cirno6 < Behaviour

    def initialize(entity)
        super(entity)
        @bullet = Chain.new(true, Bullet::Variant::CYAN)
        @cd = 0.0
        @cycle = 0
        @shot = 0
        @behaviour_cd_max = 1
        @aim_angle = nil
        @color = Omega::Color::CYAN
    end

    def reset
        @cd = 0.0
        @cycle = 0
        @shot = 5
        @pos = nil
        @aim_angle = nil
        super
    end

    def init
        @pos ||= Omega::Vector2.new(rand(100..900), rand(100..400))
        @entity.position.x += (@pos.x - @entity.position.x) * 0.05 * (@entity.phase + 1)
        @entity.position.y += (@pos.y - @entity.position.y) * 0.05 * (@entity.phase + 1)
        if Omega.in_range(@entity.position, @pos, 20)
            @inited = true
        end
    end

    def aim(origin)
        position = $player.get_position_of_player($player.get_random_player)
        return Math::atan2(position.y - origin.y, position.x - origin.x) * 180.0 / Math::PI
    end

    def behave
        if @cd <= 0.0 && @shot > 0
            if @aim_angle == nil
                @aim_angle = aim(@entity.position)
                @bullet.add_bullet_at_with_rot_with_len(@entity.position.x, @entity.position.y, @aim_angle, 10)
            else
                @bullet.add_bullet_at_with_rot_with_len(@entity.position.x, @entity.position.y, @aim_angle + @cycle, 10)
                @bullet.add_bullet_at_with_rot_with_len(@entity.position.x, @entity.position.y, @aim_angle - @cycle, 10)
            end
            @cycle += 10
            @shot -= 1
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

class Cirno7 < Behaviour

    def initialize(entity)
        super(entity)
        @bullet = SpellBullet.new(true, Bullet::Variant::CYAN)
        @color = Omega::Color::CYAN
        @behaviour_cd_max = 5
    end

    def reset
        super
    end

    def init
        @pos ||= Omega::Vector2.new(rand(100..900), rand(100..400))
        @entity.position.x += (@pos.x - @entity.position.x) * 0.05 * (@entity.phase + 1)
        @entity.position.y += (@pos.y - @entity.position.y) * 0.05 * (@entity.phase + 1)
        if Omega.in_range(@entity.position, @pos, 20)
            @inited = true
        end
    end

    def aim(origin)
        position = $player.get_position_of_player($player.get_random_player)
        return Math::atan2(position.y - origin.y, position.x - origin.x) * 180.0 / Math::PI
    end

    def behave
        tmp = @bullet.copy_at(@entity.position.x, @entity.position.y)
        tmp.bullet_angle = aim(@entity.position)
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

class Whiterock < Boss

    def initialize()
        super("assets/textures/character/whiterock.png", 5, 1.5, 64, [200, 250, 300], 3, IceBiome.new())
        @sleep = 0
        @phase = 0
        @type = 0
        @behaviours = [
            [
                Whiterock1.new(self),
                Whiterock2.new(self),
                Whiterock3.new(self),
                Whiterock4.new(self)
            ],
            [
                Whiterock1.new(self),
                Whiterock2.new(self),
                Whiterock3.new(self),
                Whiterock5.new(self)
            ],
            [
                Whiterock1.new(self),
                Whiterock2.new(self),
                Whiterock4.new(self),
                Whiterock6.new(self)
            ]
        ]
        @probs = [
            [
                0.25,
                0.25,
                0.25,
                0.25
            ],
            [
                0.3,
                0.1,
                0.3,
                0.3
            ],
            [
                0.2,
                0.5,
                0.2,
                0.1
            ]
        ]
        @env.level_up()
        @env.level_up()
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
        # super
        # # if not @behaviours[@phase][@type].can_init?
        # #     @type = rand(0...@behaviours[@phase])
        # #     return
        # # end
        # # if not @behaviours[@phase][@type].has_init?
        # #     @behaviours[@phase][@type].init
        # #     @cast = true
        # #     @cast_color = @behaviours[@phase][@type].color
        # # elsif not @behaviours[@phase][@type].has_end?
        # #     @behaviours[@phase][@type].behave
        # # else
        # #     @cast = false
        # #     @behaviours[@phase][@type].behaviour_cd = @behaviours[@phase][@type].behaviour_cd_max / (@phase + 1)
        # # end
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
                @sleep = @behaviours[@phase][@type].behaviour_cd_max / (@phase + 1)
            end
        end
    end

end

class Whiterock1 < Behaviour

    def initialize(entity)
        super(entity)
        @index = 1
        @bullet = Idk.new(true, Bullet::Variant::RED)
        @behaviour_cd_max = 0
        @color = Spell::RED
        @angle = 0.0
        @pos = nil
        @cd = 0.0
        @shot = 0
        @dest = nil
    end

    def reset
        @pos = nil
        @angle = nil
        @dest = nil
        @index = 1
        @shot = 10
        @cd = 0.0
        super
    end

    def init
        @pos ||= Omega::Vector2.new(rand(100..900), rand(100..400))
        @angle ||= rand(-15..15) + ((@pos.x > (Omega.width / 2)) ? 180 : 0)
        @dest ||= Omega::Vector2.new(
            @pos.x + 500 * Math::cos(Omega.to_rad(@angle)),
            @pos.y + 500 * Math::sin(Omega.to_rad(@angle))
        )
        @entity.position.x += (@pos.x - @entity.position.x) * 0.2 * (@entity.phase + 1)
        @entity.position.y += (@pos.y - @entity.position.y) * 0.2 * (@entity.phase + 1)
        if Omega.in_range(@entity.position, @pos, 20)
            @inited = true
        end
    end

    def aim(origin)
        position = $player.get_position_of_player($player.get_random_player)
        return Math::atan2(position.y - origin.y, position.x - origin.x) * 180.0 / Math::PI
    end

    def behave
        @entity.position.x += (@dest.x - @entity.position.x) * 0.2 * (@entity.phase + 1)
        @entity.position.y += (@dest.y - @entity.position.y) * 0.2 * (@entity.phase + 1)
        @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, aim(@entity.position))
        if @entity.phase == 1
            @bullet.add_bullet_at_with_rot(@entity.position.x - 50, @entity.position.y, aim(@entity.position))
            @bullet.add_bullet_at_with_rot(@entity.position.x + 50, @entity.position.y, aim(@entity.position))
        end
        if Omega.in_range(@entity.position, @dest, 10)
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

class Whiterock2 < Behaviour

    def initialize(entity)
        super(entity)
        @bullet = Chain.new(true, Bullet::Variant::RED)
        @cd = 0.0
        @cycle = 0
        @shot = 0
        @behaviour_cd_max = 1
        @aim_angle = nil
        @color = Omega::Color::RED
    end

    def reset
        @cd = 0.0
        @cycle = 0
        @shot = 10
        @pos = nil
        @aim_angle = nil
        super
    end

    def init
        @pos ||= Omega::Vector2.new(rand(100..900), rand(100..400))
        @entity.position.x += (@pos.x - @entity.position.x) * 0.2 * (@entity.phase + 1)
        @entity.position.y += (@pos.y - @entity.position.y) * 0.2 * (@entity.phase + 1)
        if Omega.in_range(@entity.position, @pos, 20)
            @inited = true
        end
    end

    def aim(origin)
        position = $player.get_position_of_player($player.get_random_player)
        return Math::atan2(position.y - origin.y, position.x - origin.x) * 180.0 / Math::PI
    end

    def behave
        if @cd <= 0.0 && @shot > 0
            if @aim_angle == nil
                @bullet.add_bullet_at_with_rot_with_len(@entity.position.x, @entity.position.y, @aim_angle, 10, Bullet::Variant::RED)
            else
                @bullet.add_bullet_at_with_rot_with_len(@entity.position.x, @entity.position.y, @aim_angle + @cycle, 10 - (9 - @shot), Bullet::Variant::RED)
                @bullet.add_bullet_at_with_rot_with_len(@entity.position.x, @entity.position.y, @aim_angle - @cycle, 10 - (9 - @shot), Bullet::Variant::RED)
            end
            @cycle += 5
            @shot -= 1
            @aim_angle
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

class Whiterock3 < Behaviour

    def initialize(entity)
        super(entity)
        @bullet = Pellet.new(true, Bullet::Variant::RED)
        @cd = 0.0
        @shot = 5
        @behaviour_cd_max = 0.0
        @color = Omega::Color::RED
    end

    def reset
        @cd = 0.0
        @cycle = 0
        @shot = 10
        @pos = nil
        @aim_angle = nil
        super
    end

    def init
        @pos ||= Omega::Vector2.new(rand(100..900), rand(100..400))
        @entity.position.x += (@pos.x - @entity.position.x) * 0.2 * (@entity.phase + 1)
        @entity.position.y += (@pos.y - @entity.position.y) * 0.2 * (@entity.phase + 1)
        if Omega.in_range(@entity.position, @pos, 20)
            @inited = true
        end
    end

    def aim(origin)
        position = $player.get_position_of_player($player.get_random_player)
        return Math::atan2(position.y - origin.y, position.x - origin.x) * 180.0 / Math::PI
    end

    def behave
        if @cd <= 0.0 && @shot > 0
            @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, aim(@entity.position) - 15 + rand(-2..2))
            @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, aim(@entity.position) - 10 + rand(-2..2))
            @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, aim(@entity.position) - 5 + rand(-2..2))
            @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, aim(@entity.position) + rand(-2..2))
            @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, aim(@entity.position) + 5 + rand(-2..2))
            @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, aim(@entity.position) + 10 + rand(-2..2))
            @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, aim(@entity.position) + 15 + rand(-2..2))
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

class Whiterock4 < Behaviour

    def initialize(entity)
        super(entity)
        @bullet = Pellet.new(true, Bullet::Variant::RED)
        @cd = 0.0
        @shot = 30
        @behaviour_cd_max = 1
        @color = Omega::Color::RED
    end

    def reset
        @cd = 0.0
        @cycle = 0
        @shot = 18
        @pos = nil
        @aim_angle = nil
        super
    end

    def init
        @pos ||= Omega::Vector2.new(rand(100..900), rand(100..400))
        @entity.position.x += (@pos.x - @entity.position.x) * 0.2 * (@entity.phase + 1)
        @entity.position.y += (@pos.y - @entity.position.y) * 0.2 * (@entity.phase + 1)
        @aim_angle = rand(0...360)
        if Omega.in_range(@entity.position, @pos, 20)
            @inited = true
        end
    end

    def aim(origin)
        position = $player.get_position_of_player($player.get_random_player)
        return Math::atan2(position.y - origin.y, position.x - origin.x) * 180.0 / Math::PI
    end

    def behave
        $stop = true
        if @cd <= 0.0 && @shot > 0
            pos = $player.get_position_of_player($player.get_random_player)
            @bullet.add_bullet_at_with_rot(
                pos.x + 350 * Math::cos(@aim_angle * Math::PI / 180),
                pos.y + 350 * Math::sin(@aim_angle * Math::PI / 180),
                @aim_angle + 180)
            @shot -= 1
            @cd = 0.01
            @aim_angle += 20
        else
            if @shot == 0
                $stop = false
                @ended = true
            else
                if @cd > 0.0
                    @cd -= 1.0 / 60.0
                end
            end
        end
        super
    end

    def has_init?
        return @inited
    end

    def has_end?
        return @ended
    end

end

class Whiterock5 < Behaviour

    def initialize(entity)
        super(entity)
        @bullet = Pellet.new(true, Bullet::Variant::RED)
        @cd = 0.0
        @shot = 30
        @behaviour_cd_max = 1
        @color = Omega::Color::RED
    end

    def reset
        @cd = 0.0
        @cycle = 0
        @shot = 18
        @pos = nil
        @aim_angle = nil
        super
    end

    def init
        @pos ||= Omega::Vector2.new(rand(100..900), rand(100..400))
        @entity.position.x += (@pos.x - @entity.position.x) * 0.2 * (@entity.phase + 1)
        @entity.position.y += (@pos.y - @entity.position.y) * 0.2 * (@entity.phase + 1)
        @aim_angle = rand(0...360)
        if Omega.in_range(@entity.position, @pos, 20)
            @inited = true
        end
    end

    def aim(origin)
        position = $player.get_position_of_player($player.get_random_player)
        return Math::atan2(position.y - origin.y, position.x - origin.x) * 180.0 / Math::PI
    end

    def behave
        $stop = true
        if @cd <= 0.0 && @shot > 0
            pos = $player.get_position_of_player($player.get_random_player)
            @bullet.add_bullet_at_with_rot(
                pos.x + 350 * Math::cos(@aim_angle * Math::PI / 180),
                pos.y + 350 * Math::sin(@aim_angle * Math::PI / 180),
                @aim_angle + 180)
            @bullet.add_bullet_at_with_rot(
                pos.x + 450 * Math::cos(@aim_angle * Math::PI / 180),
                pos.y + 450 * Math::sin(@aim_angle * Math::PI / 180),
                @aim_angle + 180 + 10)
            @bullet.add_bullet_at_with_rot(
                pos.x + 550 * Math::cos(@aim_angle * Math::PI / 180),
                pos.y + 550 * Math::sin(@aim_angle * Math::PI / 180),
                @aim_angle + 180)
            @shot -= 1
            @cd = 0.01
            @aim_angle += 20
        else
            if @shot == 0
                $stop = false
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

class Whiterock6 < Behaviour

    def initialize(entity)
        super(entity)
        @bullet = Pellet.new(true, Bullet::Variant::RED)
        @cd = 0.0
        @shot = 100
        @behaviour_cd_max = 1
        @aim_angle = 0
        @color = Omega::Color::RED
    end

    def reset
        @cd = 0.0
        @cycle = 0
        @shot = 100
        @pos = nil
        @aim_angle = 0
        super
    end

    def init
        @entity.position.x += (500 - @entity.position.x) * 0.2 * (@entity.phase + 1)
        @entity.position.y += (500 - @entity.position.y) * 0.2 * (@entity.phase + 1)
        if Omega.in_range(@entity.position, Omega::Vector2.new(500, 500), 20)
            @inited = true
        end
    end

    def aim(origin)
        position = $player.get_position_of_player($player.get_random_player)
        return Math::atan2(position.y - origin.y, position.x - origin.x) * 180.0 / Math::PI
    end

    def behave
        if @cd <= 0.0 && @shot > 0
            @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, @aim_angle)
            @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, @aim_angle + 45)
            @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, @aim_angle + 90)
            @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, @aim_angle + 135)
            @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, @aim_angle + 180)
            @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, @aim_angle + 225)
            @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, @aim_angle + 270)
            @bullet.add_bullet_at_with_rot(@entity.position.x, @entity.position.y, @aim_angle + 315)
            @shot -= 1
            @cd = 0.1
            @aim_angle += 2
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
