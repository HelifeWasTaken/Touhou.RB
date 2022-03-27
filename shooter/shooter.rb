class Shooter

    attr_accessor :cd

    def initialize(bullet_type, cooldown)
        @bullet = bullet_type
        @cd = 0
        @max_cd = cooldown

        @bullet.set_origin(0.5)
    end

    def shoot(); end

    def update()
        cooldown()
    end

    def cooldown()
        if (@cd > 0.0)
            @cd -= (1.0 / 60)
        end
    end

    def draw; end

    def on_stop; end

end

class RafaleShooter < Shooter

    def initialize(bullet_type, cooldown, amount, rafale_cd)
        super(bullet_type, cooldown)
        @pos = Omega::Vector2.new(0, 0)
        @amount = amount
        @shot = @amount
        @rafale_cd = 0
        @rafale_cd_max = rafale_cd
    end

    def shoot(x, y)
        if (@cd <= 0.0)
            @pos = Omega::Vector2.new(x, y)
            @cd = @max_cd
            @shot = 0
        end
    end

    def rafale_cooldown()
        if (@rafale_cd > 0.0)
            @rafale_cd -= (1.0 / 60)
        end
    end

    def update()
        rafale_cooldown()
        if (@rafale_cd <= 0.0 && @shot < @amount)
            $bullets.push(@bullet.copy_at(@pos.x, @pos.y))
            @shot += 1
            @rafale_cd = @rafale_cd_max
        end
        if @shot >= @amount
            cooldown()
        end
    end

    def cooldown()
        super()
    end

end

class PeasShooter < Shooter

    attr_accessor :level

    def initialize(isEnemy)
        super(Knife.new(isEnemy), 0.05)
        @level = 0;
    end

    def shoot(x, y)
        if (@cd <= 0.0)
            if @level == 0
                @bullet.add_bullet_at_with_rot(x, y, -90)
            end
            if @level == 1
                @bullet.add_bullet_at_with_rot(x - 10, y, -90)
                @bullet.add_bullet_at_with_rot(x + 10, y, -90)
            end
            if @level == 2
                @bullet.add_bullet_at_with_rot(x, y, -92)
                @bullet.add_bullet_at_with_rot(x, y, -90)
                @bullet.add_bullet_at_with_rot(x, y, -88)
            end
            if @level == 3
                @bullet.add_bullet_at_with_rot(x, y, -94)
                @bullet.add_bullet_at_with_rot(x, y, -92)
                @bullet.add_bullet_at_with_rot(x, y, -90)
                @bullet.add_bullet_at_with_rot(x, y, -88)
                @bullet.add_bullet_at_with_rot(x, y, -86)
            end
            if @level == 4
                @bullet.add_bullet_at_with_rot(x, y, -94)
                @bullet.add_bullet_at_with_rot(x, y, -93)
                @bullet.add_bullet_at_with_rot(x, y, -92)
                @bullet.add_bullet_at_with_rot(x, y, -91)
                @bullet.add_bullet_at_with_rot(x, y, -90)
                @bullet.add_bullet_at_with_rot(x, y, -89)
                @bullet.add_bullet_at_with_rot(x, y, -88)
                @bullet.add_bullet_at_with_rot(x, y, -87)
                @bullet.add_bullet_at_with_rot(x, y, -86)
            end
            @cd = @max_cd
        end
    end

    def cooldown()
        super()
    end

end

class LineShooter < Shooter

    attr_accessor :level

    def initialize(isEnemy)
        super(Idk.new(isEnemy, Bullet::Variant::CYAN), 1)
        @pos = Omega::Vector2.new(0, 0);
        @level = 0;
        @tmp = []
        @tmp_pos = []
    end

    def shoot(x, y)
        if (@cd <= 0.0)
            @pos = Omega::Vector2.new(x, y);
            @tmp << @bullet.copy_at(@pos.x, @pos.y);
            @tmp_pos << Omega::Vector2.new(@pos.x, @pos.y);
            for i in 0...24
                @tmp << @bullet.copy_at(@pos.x, @pos.y);
                @tmp_pos << Omega::Vector2.new(@pos.x - 25 * (i + 1), @pos.y);
                @tmp << @bullet.copy_at(@pos.x, @pos.y);
                @tmp_pos << Omega::Vector2.new(@pos.x + 25 * (i + 1), @pos.y);
            end
            @cd = @max_cd
        end
    end

    def aim(bullet)
        bullet.angle = Math::atan2($player.position.y - bullet.y, $player.position.x - bullet.x) * 180 / Math::PI
    end

    def update()
        line_up()
        super
    end

    def line_up()
        i = 0
        for i in 0...@tmp.size
            if @tmp[i].nil?
                next;
            end
            @tmp[i].position.x += (@tmp_pos[i].x - @tmp[i].position.x) * 0.1
            self.aim(@tmp[i])
            if (Omega.in_range(@tmp[i].position, @tmp_pos[i], 10))
                @bullet.add_bullet(@tmp[i])
                @tmp.delete_at(i)
                @tmp_pos.delete_at(i)
            end
        end
    end

    def draw
        for b in @tmp
            b.draw
        end
    end

end

class SplitShooter < Shooter

    attr_accessor :level

    def initialize(isEnemy)
        super(SplitBoi.new(isEnemy, Bullet::Variant::CYAN), 1)
        @pos = Omega::Vector2.new(0, 0);
        @level = 0;
        @tmp = []
        @tmp_pos = []
    end

    def shoot(x, y)
        if (@cd <= 0.0)
                @bullet.add_bullet_at_with_rot(x, y, 90, Bullet::Variant::CYAN)
            @cd = @max_cd
        end
    end

end

class PelletShooter < Shooter

    attr_accessor :level

    def initialize(isEnemy)
        super(Pellet.new(isEnemy), 1)
        @pos = Omega::Vector2.new(0, 0);
        @level = 0;
        @tmp = []
        @tmp_pos = []
    end

    def shoot(x, y)
        if (@cd <= 0.0)
            @pos = Omega::Vector2.new(x, y);
            for i in 0...36
                @tmp << @bullet.copy_at(@pos.x, @pos.y);
                @tmp[i].angle = i * 10
                @tmp_pos << Omega::Vector2.new(@pos.x + 100 * Math::cos(i * 45 * Math::PI / 180), @pos.y + 100 * Math::sin(i * 45 * Math::PI / 180));
            end
            @cd = @max_cd
        end
    end

    def update()
        line_up()
        super
    end

    def line_up()
        i = 0
        for i in 0...@tmp.size
            if @tmp[i].nil?
                next;
            end
            @tmp[i].position.x += (@tmp_pos[i].x - @tmp[i].position.x) * 0.1
            @tmp[i].position.y += (@tmp_pos[i].y - @tmp[i].position.y) * 0.1
            if (Omega.in_range(@tmp[i].position, @tmp_pos[i], 10))
                @bullet.add_bullet(@tmp[i])
                @tmp.delete_at(i)
                @tmp_pos.delete_at(i)
            end
        end
    end

    def draw
        for b in @tmp
            b.draw
        end
    end

end

class Pellet2Shooter < Shooter

    attr_accessor :level

    def initialize(isEnemy)
        super(Pellet.new(isEnemy), 1)
        @pos = Omega::Vector2.new(0, 0);
        @level = 0;
        @tmp = []
        @tmp_pos = []
    end

    def shoot(x, y)
        if (@cd <= 0.0)
            @pos = Omega::Vector2.new(x, y);
            for i in 0...36
                @tmp << @bullet.copy_at(@pos.x, @pos.y);
                @tmp[i].angle = i * 10
                @tmp_pos << Omega::Vector2.new(@pos.x + 100 * Math::cos(i * 10 * Math::PI / 180), @pos.y + 100 * Math::sin(i * 10 * Math::PI / 180));
            end
            @cd = @max_cd
        end
    end

    def update()
        line_up()
        super
    end

    def aim(bullet)
        bullet.angle = Math::atan2(0 - bullet.y, 250 - bullet.x) * 180 / Math::PI
    end

    def line_up()
        i = 0
        for i in 0...@tmp.size
            if @tmp[i].nil?
                next;
            end
            @tmp[i].position.x += (@tmp_pos[i].x - @tmp[i].position.x) * 0.1
            @tmp[i].position.y += (@tmp_pos[i].y - @tmp[i].position.y) * 0.1
            if (Omega.in_range(@tmp[i].position, @tmp_pos[i], 5))
                aim(@tmp[i])
                @bullet.add_bullet(@tmp[i])
                @tmp.delete_at(i)
                @tmp_pos.delete_at(i)
            end
        end
    end

    def draw
        for b in @tmp
            b.draw
        end
    end

end

class BladeShooter < Shooter

    attr_accessor :level

    def initialize(isEnemy)
        super(Blade.new(isEnemy), 1)
        @pos = Omega::Vector2.new(0, 0);
        @level = 0;
        @angle = 0
        @rafale_cd = 0
        @shot = 0
    end

    def shoot(x, y)
        if (@cd <= 0.0)
            @pos = Omega::Vector2.new(x, y);
            @shot = 36
            @cd = @max_cd
        end
    end

    def update()
        rafale()
        super
    end

    def cooldown()
        if (@rafale_cd > 0.0)
            @rafale_cd -= (1.0 / 60)
        end
        if @shot == 0
            super
        end
    end

    def rafale()
        if @rafale_cd <= 0.0 && @shot > 0
            @bullet.add_bullet_at_with_rot(@pos.x, @pos.y, @angle)
            @bullet.add_bullet_at_with_rot(@pos.x, @pos.y, @angle + 90)
            @bullet.add_bullet_at_with_rot(@pos.x, @pos.y, @angle + 180)
            @bullet.add_bullet_at_with_rot(@pos.x, @pos.y, @angle + 270)
            @angle -= 25
            @shot -= 1
            @rafale_cd = 0.01
        end
    end

end

class Blade2Shooter < Shooter

    attr_accessor :level

    def initialize(isEnemy)
        super(Blade.new(isEnemy), 1)
        @pos = Omega::Vector2.new(0, 0);
        @level = 0;
        @angle = 0
        @rafale_cd = 0
        @shot = 0
    end

    def shoot(x, y)
        if (@cd <= 0.0)
            @pos = Omega::Vector2.new(x, y);
            @shot = 30
            @cd = @max_cd
            @angle = -30
        end
    end

    def update()
        rafale()
        super
    end

    def cooldown()
        if (@rafale_cd > 0.0)
            @rafale_cd -= (1.0 / 60)
        end
        if @shot == 0
            super
        end
    end

    def rafale()
        if @rafale_cd <= 0.0 && @shot > 0
            @bullet.add_bullet_at_with_rot(@pos.x, @pos.y, @angle - 30)
            @bullet.add_bullet_at_with_rot(@pos.x, @pos.y, @angle - 15)
            @bullet.add_bullet_at_with_rot(@pos.x, @pos.y, @angle)
            @bullet.add_bullet_at_with_rot(@pos.x, @pos.y, @angle + 15)
            @bullet.add_bullet_at_with_rot(@pos.x, @pos.y, @angle + 30)
            @angle -= 4
            @shot -= 1
            @rafale_cd = 0.05
        end
    end

end

class IdkRafale < Shooter

    attr_accessor :level

    def initialize(isEnemy)
        super(Idk.new(isEnemy), 1)
        @pos = Omega::Vector2.new(0, 0);
        @level = 0;
        @angle = 0
        @rafale_cd = 0
        @shot = 0
    end

    def shoot(x, y)
        if (@cd <= 0.0)
            @pos = Omega::Vector2.new(x, y);
            @shot = 11
            @cd = @max_cd
            @angle = -15
        end
    end

    def update()
        rafale()
        super
    end

    def cooldown()
        if (@rafale_cd > 0.0)
            @rafale_cd -= (1.0 / 60)
        end
        if @shot == 0
            super
        end
    end

    def rafale()
        if @rafale_cd <= 0.0 && @shot > 0
            @bullet.add_bullet_at_with_rot(@pos.x, @pos.y, @angle - 15)
            @bullet.add_bullet_at_with_rot(@pos.x, @pos.y, @angle - 10)
            @bullet.add_bullet_at_with_rot(@pos.x, @pos.y, @angle - 5)
            @bullet.add_bullet_at_with_rot(@pos.x, @pos.y, @angle)
            @bullet.add_bullet_at_with_rot(@pos.x, @pos.y, @angle + 5)
            @bullet.add_bullet_at_with_rot(@pos.x, @pos.y, @angle + 10)
            @bullet.add_bullet_at_with_rot(@pos.x, @pos.y, @angle + 15)
            @angle -= 15
            @shot -= 1
            @rafale_cd = 0.025
        end
    end

end

class BladeStorm < Shooter

    attr_accessor :level

    def initialize(isEnemy)
        super(StormBlade.new(isEnemy, Bullet::Variant::CYAN), 10)
        @pos = Omega::Vector2.new(0, 0);
        @level = 0;
        @angle = 0
        @rafale_cd = 0
        @shot = 0
    end

    def shoot(x, y)
        if (@cd <= 0.0)
            @pos = Omega::Vector2.new(x, y);
            @shot = 11
            @cd = @max_cd
            @angle = 0
        end
    end

    def update()
        rafale()
        super
    end

    def cooldown()
        if (@rafale_cd > 0.0)
            @rafale_cd -= (1.0 / 60)
        end
        if @shot == 0
            super
        end
    end

    def rafale()
        if @rafale_cd <= 0.0 && @shot > 0
            for _ in 0...18
                @bullet.add_bullet_at_with_rot(@pos.x, @pos.y, @angle, Bullet::Variant::CYAN)
                @angle += 20
            end
            @shot -= 1
            @rafale_cd = 0.1
        end
    end

end

class ChainShooter < Shooter

    attr_accessor :level

    def initialize(isEnemy)
        super(Chain.new(isEnemy), 1)
        @level = 0;
    end

    def shoot(x, y)
        if (@cd <= 0.0)
            @bullet.add_bullet_at_with_rot_with_len(x, y, -70, 15)
            @bullet.add_bullet_at_with_rot_with_len(x, y, -80, 15)
            @bullet.add_bullet_at_with_rot_with_len(x, y, -90, 15)
            @bullet.add_bullet_at_with_rot_with_len(x, y, -100, 15)
            @bullet.add_bullet_at_with_rot_with_len(x, y, -110, 15)
            @cd = @max_cd
        end
    end

    def cooldown()
        super()
    end

end

class ChainRafale < Shooter

    attr_accessor :level

    def initialize(isEnemy)
        super(Chain.new(isEnemy), 1)
        @pos = Omega::Vector2.new(0, 0);
        @level = 0;
        @angle = 0
        @rafale_cd = 0
        @shot = 0
        @shot_max = 25
    end

    def shoot(x, y)
        if (@cd <= 0.0)
            @pos = Omega::Vector2.new(x, y);
            @shot = @shot_max
            @cd = @max_cd
            @angle = -90
        end
    end

    def update()
        rafale()
        super
    end

    def cooldown()
        if (@rafale_cd > 0.0)
            @rafale_cd -= (1.0 / 60)
        end
        if @shot == 0
            super
        end
    end

    def rafale()
        if @rafale_cd <= 0.0 && @shot > 0
            @bullet.add_bullet_at_with_rot_with_len(@pos.x, @pos.y, @angle - (5 * (@shot - @shot_max)), 15)
            if @shot < @shot_max
                @bullet.add_bullet_at_with_rot_with_len(@pos.x, @pos.y, @angle + (5 * (@shot - @shot_max)), 15)
            end
            @shot -= 1
            @rafale_cd = 0.1
        end
    end

end

class BladeStop < Shooter

    attr_accessor :level

    def initialize(isEnemy)
        super(Blade.new(isEnemy, Bullet::Variant::CYAN), 1)
        @pos = Omega::Vector2.new(0, 0);
        @level = 0;
        @tmp_pos = []
        @tmp_angle = []
        @tmp = []
        @rafale_cd = 0
        @shot = 0
        @shot_max = 10
        @aim = Omega::Vector2.new(0, 0);
        @angle = 0
        @delta = 0
    end

    def shoot(x, y)
        if (@cd <= 0.0)
            @pos = $player.position;
            @angle = rand(-120..-70)
            @delta = 0
            for i in 0...@shot_max
                @tmp_pos << Omega::Vector2.new(@pos.x + (i + 10) * 25 * Math::cos((@angle - 50 - @delta * 5) * Math::PI / 180), @pos.y + (i + 10) * 25 * Math::sin((@angle - 50 - @delta * 5) * Math::PI / 180))
                @tmp_angle << aim(@tmp_pos[-1], $player.position)
                @tmp_pos << Omega::Vector2.new(@pos.x + (i + 10) * 25 * Math::cos(@angle * Math::PI / 180), @pos.y + (i + 10) * 25 * Math::sin(@angle * Math::PI / 180))
                @tmp_angle << aim(@tmp_pos[-1], $player.position)
                @tmp_pos << Omega::Vector2.new(@pos.x + (i + 10) * 25 * Math::cos((@angle + 50 + @delta * 5) * Math::PI / 180), @pos.y + (i + 10) * 25 * Math::sin((@angle + 50 + @delta * 5) * Math::PI / 180))
                @tmp_angle << aim(@tmp_pos[-1], $player.position)
                @tmp_pos << Omega::Vector2.new(@pos.x + (i + 10) * 25 * Math::cos((@angle - 100 - @delta * 5) * Math::PI / 180), @pos.y + (i + 10) * 25 * Math::sin((@angle - 100 - @delta * 5) * Math::PI / 180))
                @tmp_angle << aim(@tmp_pos[-1], $player.position)
                @tmp_pos << Omega::Vector2.new(@pos.x + (i + 10) * 25 * Math::cos((@angle + 100 + @delta * 5) * Math::PI / 180), @pos.y + (i + 10) * 25 * Math::sin((@angle + 100 + @delta * 5) * Math::PI / 180))
                @tmp_angle << aim(@tmp_pos[-1], $player.position)
                @delta += 1
            end
            @shot = @shot_max
            @cd = @max_cd
            $stop = true
        end
    end

    def aim(origin, at)
        return Math::atan2(at.y - origin.y, at.x - origin.x) * 180 / Math::PI
    end

    def update()
        super
    end

    def on_stop()
        line_up()
        if (@rafale_cd > 0.0)
            @rafale_cd -= (1.0 / 60)
        end
        if @shot == 0
            $stop = false
            @tmp_pos = []
            @tmp_angle = []
            for b in @tmp
                b.add_bullet(b, Bullet::Variant::CYAN)
            end
            @tmp = []
        end
    end

    def line_up()
        if @rafale_cd <= 0.0 && @shot > 0
            @shot -= 1
            for i in 0...5
                for j in 0...3
                    @tmp << @bullet.copy_at(@tmp_pos[@shot * 5 + i].x, @tmp_pos[@shot * 5 + i].y)
                    @tmp[-1].angle = @tmp_angle[@shot * 5 + i] + (-30 + 30 * j)
                    @tmp[-1].set_variant(Bullet::Variant::RED)
                end
            end
            @rafale_cd = 0.05
        end
    end

    def draw
        for b in @tmp
            b.draw
        end
    end

end
