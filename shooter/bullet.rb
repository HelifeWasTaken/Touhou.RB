class Bullet < Omega::Sprite

    attr_accessor :angle, :speed, :rect, :destroy_on_hit, :damage, :lifetime, :variant

    module Variant
        RED = 0
        MAGENTA = 1
        BLUE = 2
        CYAN = 3
        GREEN = 4
        YELLOW = 5
    end

    def initialize(sprite, size, variant, speed, isEnemy, lifetime = 500)
        super(sprite)
        @sprite = sprite
        @speed = speed
        @angle = 0
        @lifetime = lifetime
        @damage = 0
        @rect = nil
        @damage = 0
        @isEnemy = isEnemy
        @variant = variant
        @variants = []
        @clear = Clear.new()
        self.scale = Omega::Vector2.new(0.5, 0.5)
        self.set_origin(0.5)

        for i in 0...6
            @variants[i] = self.image.subimage(0, size * i, size, size)
        end
    end

    def die
        if @isEnemy
            $enemy_bullets.delete(self)
        else
            $player_bullets.delete(self)
        end
    end

    def clear
        @clear.emit_at(@position.x, @position.y)
        die
    end

    def go_f4st()
        @rect.x = @position.x - @rect.width / 2
        @rect.y = @position.y - @rect.height / 2
        if @lifetime < 0 or not out_of_bounds
            die
        end
        @lifetime -= 1
        if @angle.nil?
            return;
        end
        self.x += @speed * Math::cos(Omega::to_rad(@angle))
        self.y += @speed * Math::sin(Omega::to_rad(@angle))
    end

    def set_variant(id)
        self.variant = id
    end

    def draw()
        if @variants[@variant].nil?
            return
        end
        if @angle.nil?
            return
        end
        @variants[@variant].draw_rot((@flip.x) ? @position.x + @width * @scale.x - @width*2 * @scale.x * @origin.x : @position.x,
        (@flip.y) ? @position.y + @height * @scale.y - @height*2 * @scale.y * @origin.y : @position.y,
        @position.z,
        @angle,
        @origin.x,
        @origin.y,
        (@flip.x) ? -@scale.x : @scale.x,
        (@flip.y) ? -@scale.y : @scale.y,
        @color,
        @mode) if @visible
        # @rect.color = Omega::Color::RED
        # @rect.draw
    end

    def on_hit()
        die
    end

    def out_of_bounds()
        if (@position.x >= -Omega.width and @position.x <= Omega.width * 2 and @position.y >= -Omega.height and @position.y <= Omega.height * 2)
            return true
        end
        return false
    end

    def copy_at(x, y)
        bullet = self.class.new(@isEnemy, @variant)
        bullet.x = x
        bullet.y = y
        return bullet
    end

    def add_bullet_at_with_rot(x=self.x, y=self.y, angle=0.0, variant=nil)
        tmp = self.copy_at(x, y)
        tmp.angle = angle
        if variant.nil?
            tmp.set_variant(self.variant)
        else
            tmp.set_variant(variant)
        end
        if @isEnemy
            $enemy_bullets << tmp
        else
            $player_bullets << tmp
        end
    end

    def add_bullet_with_rot(angle, variant=nil)
        tmp = self.copy_at(self.x, self.y)
        tmp.angle = angle
        if variant.nil?
            tmp.set_variant(self.variant)
        else
            tmp.set_variant(variant)
        end
        if @isEnemy
            $enemy_bullets << tmp
        else
            $player_bullets << tmp
        end
    end

    def add_bullet_at(x=self.x, y=self.y, variant=nil)
        tmp = self.copy_at(x, y)
        if variant.nil?
            tmp.set_variant(self.variant)
        else
            tmp.set_variant(variant)
        end
        if @isEnemy
            $enemy_bullets << tmp
        else
            $player_bullets << tmp
        end
    end

    def add_bullet(bullet, variant=nil)
        if variant.nil?
            bullet.set_variant(self.variant)
        else
            bullet.set_variant(variant)
        end
        if @isEnemy
            $enemy_bullets << bullet
        else
            $player_bullets << bullet
        end
    end

    def isEnemy
        return @isEnemy
    end

end

class Knife < Bullet

    def initialize(isEnemy, variant=Variant::CYAN)
        super("assets/textures/bullet/knife.png", 32, variant, 25, isEnemy)
        @rect = Omega::Rectangle.new(0, 0, 16, 16)
        @damage = 1
        set_scale(2)
    end

end

class Idk < Bullet

    def initialize(isEnemy, variant=Variant::CYAN)
        super("assets/textures/bullet/idk.png", 16, variant, 0, isEnemy)
        @rect = Omega::Rectangle.new(0, 0, 8, 8)
        @damage = 1
        @top_speed = 25
        set_scale(2)
    end

    def go_f4st()
        @speed += (@top_speed - @speed) * 0.01
        super()
    end

end

class SplitBoi < Bullet

    def initialize(isEnemy, variant=Variant::CYAN)
        super("assets/textures/bullet/warp.png", 32, variant, 15, isEnemy, 50)
        @rect = Omega::Rectangle.new(0, 0, 24, 24)
        @damage = 1
        @top_speed = 0
        set_scale(2)
    end

    def go_f4st()
        @speed += (@top_speed - @speed) * 0.05
        super()
    end

    def die()
        bullet = Idk.new(@isEnemy, @variant)
        bullet.position = @position
        bullet.add_bullet(bullet, @variant)
        for i in 1...36
            bullet.add_bullet_with_rot(i * 10, @variant)
        end
        super()
    end

    def on_hit()
        super()
    end

end

# class SplitBoi < Bullet

#     def initialize(isEnemy, variant=Variant::CYAN)
#         super("assets/textures/bullet/warp.png", 32, variant, 15, isEnemy, 50)
#         @rect = Omega::Rectangle.new(0, 0, 4, 4)
#         @damage = 1
#         @top_speed = 0
#         set_scale(2)
#     end

#     def go_f4st()
#         @rect.x = self.x
#         @rect.y = self.y
#         @speed += (@top_speed - @speed) * 0.05
#         super()
#     end

#     def die()
#         bullet = Idk.new(@isEnemy, @variant)
#         bullet.position = @position
#         bullet.add_bullet(bullet, @variant)
#         for i in 1...36
#             bullet.add_bullet_with_rot(i * 10, @variant)
#         end
#         super()
#     end

#     def on_hit()
#         super()
#     end

# end

class SnowFlake < Bullet

    def initialize(isEnemy, variant=Variant::CYAN)
        super("assets/textures/bullet/snow.png", 32, variant, 5, isEnemy, 250)
        @rect = Omega::Rectangle.new(0, 0, 16, 16)
        @damage = 1
        @revert = 1
        @bullet_angle = 90
        set_scale(2)
    end

    def go_f4st()
        @rect.x = @position.x - @rect.width / 2
        @rect.y = @position.y - @rect.height / 2
        if @base.nil?
            @base = @position.x
        end
        @angle += 4
        if @lifetime < 0 or not out_of_bounds
            die
        end
        @lifetime -= 1
        self.x += @speed * Math::cos(Omega::to_rad(@bullet_angle))
        self.y += @speed * Math::sin(Omega::to_rad(@bullet_angle))
    end

end

class Pellet < Bullet

    def initialize(isEnemy, variant=Variant::CYAN)
        super("assets/textures/bullet/pellet.png", 16, variant, 5, isEnemy)
        @rect = Omega::Rectangle.new(0, 0, 8, 8)
        @damage = 1
        set_scale(2)
    end

end

class Blade < Bullet

    def initialize(isEnemy, variant=Variant::CYAN)
        super("assets/textures/bullet/blade.png", 32, variant, 5, isEnemy)
        @rect = Omega::Rectangle.new(0, 0, 16, 16)
        @damage = 1
        set_scale(2)
    end

end

class StormBlade < Bullet

    def initialize(isEnemy, variant=Variant::CYAN)
        super("assets/textures/bullet/blade.png", 32, variant, 5, isEnemy, 500)
        @rect = Omega::Rectangle.new(0, 0, 16, 16)
        @damage = 1
        set_scale(2)
    end

    def go_f4st()
        @angle += 5
        @speed += 0.1
        super()
    end

end

class Chain < Bullet

    attr_accessor :global_angle, :len

    def initialize(isEnemy, variant=Variant::CYAN)
        super("assets/textures/bullet/idk.png", 16, variant, 8, isEnemy, 500)
        @rect = Omega::Rectangle.new(0, 0, 8, 8)
        @damage = 1
        @chain = Pellet.new(isEnemy, variant)
        @global_angle
        @len = 10
        set_scale(2)
    end
    def add_bullet_at_with_rot_with_len(x, y, angle, len,  variant=Variant::CYAN)
        self.global_angle = angle
        self.len = len
        self.set_variant(variant)
        tmp = self.copy_at(x, y)
        tmp.angle = angle
        if @isEnemy
            $enemy_bullets << tmp
        else
            $player_bullets << tmp
        end
    end

    def add_bullet_at_with_rot(x, y, angle, variant=Variant::CYAN)
        self.global_angle = angle
        tmp.set_variant(variant)
        tmp = self.copy_at(x, y)
        tmp.angle = angle
        if @isEnemy
            $enemy_bullets << tmp
        else
            $player_bullets << tmp
        end
    end

    def copy_at(x, y)
        tmp = nil
        for i in 1...@len
            tmp = @chain.copy_at(x, y)
            tmp.set_variant(@variant)
            tmp.angle = @global_angle
            tmp.speed = @speed * (1 - 0.05 * i)
            tmp.lifetime = 500
            tmp.add_bullet(tmp)
        end
        super(x, y)
    end

end

class Circle < Bullet

    attr_accessor :pellet

    def initialize(isEnemy, variant=Variant::CYAN)
        super("assets/textures/bullet/knife.png", 32, variant, 10, isEnemy)
        @rect = Omega::Rectangle.new(0, 0, 16, 16)
        @damage = 1
        @pellet = []
        @cycle = 0
        @cycle_speed = 10
        set_scale(2)
    end

    def go_f4st()
        for p in @pellet
            p.position.x = @position.x + 50 * Math::cos(Omega::to_rad(@cycle))
            p.position.y = @position.y + 50 * Math::sin(Omega::to_rad(@cycle))
            p.angle = @cycle + 90
            @cycle += 45
        end
        @cycle += @cycle_speed
        super()
    end

    def draw
        for p in pellet
            p.draw
        end
    end
end

class SpellBullet < Bullet

    attr_accessor :bullet_angle

    def initialize(isEnemy, variant=Variant::BLUE)
        super("assets/textures/misc/second_spell.png", 64, variant, 15, isEnemy, 1000)
        @rect = Omega::Rectangle.new(0, 0, 0, 0)
        @bullet = Pellet.new(true)
        @damage = 1
        @top_speed = 0
        @cd = 0
        set_scale(2)
    end

    def go_f4st()
        @speed += (@top_speed - @speed) * 0.05
        @rect.x = @position.x - @rect.width / 2
        @rect.y = @position.y - @rect.height / 2
        @angle += 4
        if @lifetime < 0 or not out_of_bounds
            die
        end
        @lifetime -= 1
        self.x += @speed * Math::cos(Omega::to_rad(@bullet_angle))
        self.y += @speed * Math::sin(Omega::to_rad(@bullet_angle))
        if @cd > 0.0
            @cd -= 1.0 / 60.0
        else
            for i in 0...18
                @bullet.add_bullet_at_with_rot(self.x, self.y, i * 20 + @angle)
            end
            @cd = 0.2
        end
    end

    def die()
        super()
    end

    def on_hit()
        super()
    end

end
