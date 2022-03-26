class Bullet < Omega::SpriteSheet

    attr_accessor :angle, :speed, :rect, :destroy_on_hit, :damage, :lifetime, :variant

    def initialize(sprite, size, variant, speed, isEnemy, lifetime = 500)
        super(sprite, size, size)
        @sprite = sprite
        @speed = speed
        @angle = 0
        @lifetime = lifetime
        @damage = 0
        @rect = nil
        @damage = 0
        @isEnemy = isEnemy
        @variant = variant
        self.scale = Omega::Vector2.new(0.5, 0.5)
        self.set_origin(0.5)

        add_animation("CLASSIC", [0])
        add_animation("RED", [1])
        add_animation("MAGENTA", [2])
        add_animation("BLUE", [3])
        add_animation("CYAN", [4])
        add_animation("GREEN", [5])
        add_animation("YELLOW", [6])
        add_animation("WHITE", [7])
        play_animation(variant)
    end

    def die
        if @isEnemy
            $enemy_bullets.delete(self)
        else
            $player_bullets.delete(self)
        end
    end

    def go_f4st()
        if @lifetime < 0
            die
        end
        @lifetime -= 1
        self.x += @speed * Math::cos(Omega::to_rad(@angle))
        self.y += @speed * Math::sin(Omega::to_rad(@angle))
    end

    def set_variant(id)
        play_animation(id)
    end

    def draw()
        super()
    end

    def on_hit()
        die
    end

    def on_window()
        #size
        #if (@position.x >= 0 and @position.x <= )
    end

    def copy_at(x, y)
        bullet = self.class.new(@isEnemy, @variant)
        bullet.x = x
        bullet.y = y
        return bullet
    end

    def add_bullet_at_with_rot(x=self.x, y=self.y, angle=0.0, variant="CYAN")
        tmp = self.copy_at(x, y)
        tmp.angle = angle
        tmp.set_variant(variant)
        if @isEnemy
            $enemy_bullets << tmp
        else
            $player_bullets << tmp
        end
    end

    def add_bullet_with_rot(angle, variant="CYAN")
        tmp = self.copy_at(self.x, self.y)
        tmp.angle = angle
        tmp.set_variant(variant)
        if @isEnemy
            $enemy_bullets << tmp
        else
            $player_bullets << tmp
        end
    end

    def add_bullet_at(x=self.x, y=self.y, variant="CYAN")
        tmp = self.copy_at(x, y)
        tmp.set_variant(variant)
        if @isEnemy
            $enemy_bullets << tmp
        else
            $player_bullets << tmp
        end
    end

    def add_bullet(bullet, variant="CYAN")
        bullet.set_variant(variant)
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

# class Knife < Bullet

#     def initialize(isEnemy)
#         super("assets/textures/bullet/knife.png", 16, 25, isEnemy)
#         @rect = Omega::Rectangle.new(0, 0, 4, 4)
#         @damage = 1
#     end

#     def go_f4st()
#         @rect.x = self.x
#         @rect.y = self.y
#         super()
#     end

#     def on_hit()
#         super()
#     end

# end

# class Idk < Bullet

#     def initialize(isEnemy)
#         super("assets/textures/bullet/idk.png", 0, isEnemy)
#         @rect = Omega::Rectangle.new(0, 0, 4, 4)
#         @damage = 1
#         @top_speed = 25
#         set_scale(2)
#     end

#     def go_f4st()
#         @rect.x = self.x
#         @rect.y = self.y
#         @speed += (@top_speed - @speed) * 0.01
#         super()
#     end

#     def on_hit()
#         super()
#     end

# end

# class SplitBoi < Bullet

#     def initialize(isEnemy)
#         super("assets/textures/bullet/warp.png", 15, isEnemy, 50)
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
#         bullet = Idk.new(@isEnemy)
#         bullet.position = @position
#         bullet.add_bullet(bullet)
#         for i in 1...36
#             bullet.add_bullet_with_rot(i * 10)
#         end
#         super()
#     end

#     def on_hit()
#         super()
#     end

# end

# class Pellet < Bullet

#     def initialize(isEnemy)
#         super("assets/textures/bullet/pellet.png", 5, isEnemy)
#         @rect = Omega::Rectangle.new(0, 0, 4, 4)
#         @damage = 1
#         set_scale(2)
#     end

#     def go_f4st()
#         @rect.x = self.x
#         @rect.y = self.y
#         super()
#     end

# end

class Blade < Bullet

    def initialize(isEnemy, variant)
        super("assets/textures/bullet/blade.png", 32, variant, 5, isEnemy)
        @rect = Omega::Rectangle.new(0, 0, 4, 4)
        @damage = 1
        set_scale(2)
    end

    def go_f4st()
        @rect.x = self.x
        @rect.y = self.y
        super()
    end

end

class StormBlade < Bullet

    def initialize(isEnemy, variant)
        super("assets/textures/bullet/blade.png", 32, variant, 5, isEnemy, 500)
        @rect = Omega::Rectangle.new(0, 0, 4, 4)
        @damage = 1
        set_scale(2)
    end

    def go_f4st()
        @rect.x = self.x
        @rect.y = self.y
        @angle += 5
        @speed += 0.1
        super()
    end

end

# class Chain < Bullet

#     attr_accessor :global_angle, :len

#     def initialize(isEnemy)
#         super("assets/textures/bullet/idk.png", 8, isEnemy, 500)
#         @rect = Omega::Rectangle.new(0, 0, 4, 4)
#         @damage = 1
#         @chain = Pellet.new(isEnemy)
#         @global_angle
#         @len = 10
#         set_scale(2)
#     end

#     def go_f4st()
#         @rect.x = self.x
#         @rect.y = self.y
#         super()
#     end

#     def add_bullet_at_with_rot_with_len(x, y, angle, len)
#         self.global_angle = angle
#         self.len = len
#         tmp = self.copy_at(x, y)
#         tmp.angle = angle
#         if @isEnemy
#             $enemy_bullets << tmp
#         else
#             $player_bullets << tmp
#         end
#     end

#     def add_bullet_at_with_rot(x, y, angle)
#         self.global_angle = angle
#         tmp = self.copy_at(x, y)
#         tmp.angle = angle
#         if @isEnemy
#             $enemy_bullets << tmp
#         else
#             $player_bullets << tmp
#         end
#     end

#     def copy_at(x, y)
#         tmp = nil
#         for i in 1...@len
#             tmp = @chain.copy_at(x, y)
#             tmp.angle = @global_angle
#             tmp.speed = @speed * (1 - 0.05 * i)
#             tmp.lifetime = 500
#             tmp.add_bullet(tmp)
#         end
#         super(x, y)
#     end

# end

# class Peas < Bullet

#     def initialize(isEnemy)
#         super("assets/images/bullet_1.png", 25, isEnemy)
#         @rect = Omega::Rectangle.new(0, 0, 4, 4)
#         @damage = 1
#     end

#     def go_f4st()
#         @rect.x = self.x
#         @rect.y = self.y
#         super()
#     end

#     def on_hit()
#         super()
#     end

#     def copy_at(x, y)
#         $sounds["shot"].play(0.03)
#         bullet = Peas.new(self.isEnemy)
#         bullet.x = x
#         bullet.y = y
#         return bullet
#     end

# end

# class Plasma < Bullet

#     def initialize(isEnemy)
#         super("assets/images/bullet_2.png", 2, isEnemy)
#         @rect = Omega::Rectangle.new(0, 0, 8, 8)
#         @damage = 5
#     end

#     def go_f4st()
#         @rect.x = self.x - 4
#         @rect.y = self.y - 4
#         super()
#     end

#     def on_hit()
#         super()
#     end

#     def copy_at(x, y)
#         $sounds["shot"].play(0.03)
#         bullet = Plasma.new(self.isEnemy)
#         bullet.x = x
#         bullet.y = y
#         return bullet
#     end

# end

# class ShotgunBullet < Bullet

#     def initialize(isEnemy)
#         super("assets/images/bullet_3.png", 8, isEnemy, 70)
#         @rect = Omega::Rectangle.new(5, 2, 6, 4)
#         @damage = 2
#     end

#     def go_f4st()
#         @speed -= (@speed - 0) * 0.1
#         if @speed <= 0.2
#             on_hit()
#         end
#         @rect.x = self.x
#         @rect.y = self.y
#         super()
#     end

#     def on_hit()
#         super()
#     end

#     def copy_at(x, y)
#         $sounds["shot"].play(0.03)
#         bullet = ShotgunBullet.new(self.isEnemy)
#         bullet.x = x
#         bullet.y = y
#         return bullet
#     end

# end

# class Lazor < Bullet

#     def initialize(isEnemy)
#         super("assets/images/bullet_4.png", 5, isEnemy, 70)
#         @rect = Omega::Rectangle.new(6, 0, 8, 2)
#         @destroy_on_hit = false
#         @damage = 10
#     end

#     def go_f4st()
#         @rect.x = self.x
#         @rect.y = self.y
#         super()
#     end

#     def on_hit(); end

#     def copy_at(x, y)
#         $sounds["shot"].play(0.03)
#         bullet = Lazor.new(self.isEnemy)
#         bullet.x = x
#         bullet.y = y
#         return bullet
#     end

# end

# class Mlg < Bullet

#     def initialize(isEnemy)
#         super("assets/images/bullet_5.png", 20, isEnemy, 70)
#         @rect = Omega::Rectangle.new(7, 0, 16, 1)
#         @damage = 50
#     end

#     def go_f4st()
#         @rect.x = self.x
#         @rect.y = self.y
#         super()
#     end

#     def on_hit()
#         super()
#     end

#     def copy_at(x, y)
#         $sounds["shot"].play(0.03)
#         bullet = Mlg.new(self.isEnemy)
#         bullet.x = x
#         bullet.y = y
#         return bullet
#     end

# end

# class Bomba < Bullet

#     GRAVITY = 5

#     def initialize(isEnemy)
#         super("assets/images/bullet_6.png", 0, 70)
#         @splod = BombaShrap.new(isEnemy)
#         @rect = Omega::Rectangle.new(0, 0, 6, 6)
#         @damage = 100
#     end

#     def go_f4st()
#         if @lifetime < 0
#             self.die
#             return
#         end
#         @lifetime -= 1
#         self.y += GRAVITY
#         @rect.x = self.x
#         @rect.y = self.y
#     end

#     def on_hit()
#         tmp = nil
#         for i in 0...11
#             tmp = @splod.copy_at(self.x, self.y + 25)
#             tmp.angle = i * 18 * -1
#             self.add_bullet(tmp)
#         end
#         super()
#     end

#     def copy_at(x, y)
#         $sounds["shot"].play(0.03)
#         bullet = Bomba.new(self.isEnemy)
#         bullet.x = x
#         bullet.y = y
#         return bullet
#     end

# end

# class BombaShrap < Bullet

#     def initialize(isEnemy)
#         super("assets/images/shrap.png", 4, isEnemy, 25)
#         @rect = Omega::Rectangle.new(0, 0, 6, 6)
#         @damage = 25
#     end

#     def go_f4st()
#         @rect.x = self.x - 4
#         @rect.y = self.y - 4
#         super()
#     end

#     def copy_at(x, y)
#         $sounds["shot"].play(0.03)
#         bullet = BombaShrap.new(self.isEnemy)
#         bullet.x = x
#         bullet.y = y
#         return bullet
#     end

# end

# class Needle < Bullet

#     def initialize(isEnemy)
#         super("assets/images/bullet_7.png", 10, isEnemy, 100)
#         @rect = Omega::Rectangle.new(7, 0, 16, 1)
#         @damage = 5
#     end

#     def go_f4st()
#         @rect.x = self.x
#         @rect.y = self.y
#         super()
#     end

#     def copy_at(x, y)
#         $sounds["shot"].play(0.03)
#         bullet = Needle.new(self.isEnemy)
#         bullet.x = x
#         bullet.y = y
#         return bullet
#     end

# end

# class EBullet < Bullet

#     def initialize(isEnemy)
#         super("assets/images/enemy_bullet.png", 5, isEnemy, 70)
#         @rect = Omega::Rectangle.new(0, 0, 4, 4)
#         @damage = 1
#     end

#     def go_f4st()
#         @rect.x = self.x
#         @rect.y = self.y
#         super()
#     end

#     def copy_at(x, y)
#         $sounds["shot"].play(0.03)
#         bullet = EBullet.new(self.isEnemy)
#         bullet.x = x
#         bullet.y = y
#         return bullet
#     end

# end

# class UltraBullet < Bullet

#     def initialize(isEnemy)
#         super("assets/images/enemy_bullet.png", 3, isEnemy, 200)
#         @scale = Omega::Vector2.new(1 ,1)
#         @rect = Omega::Rectangle.new(0, 0, 4, 4)
#         @damage = 2
#     end

#     def go_f4st()
#         @rect.x = self.x
#         @rect.y = self.y
#         super()
#     end

#     def copy_at(x, y)
#         $sounds["shot"].play(0.03)
#         bullet = UltraBullet.new(isEnemy)
#         bullet.x = x
#         bullet.y = y
#         return bullet
#     end

# end

# class Needle < Bullet

#     def initialize(isEnemy)
#         super("assets/images/enemy_bullet_2.png", 5, isEnemy, 120)
#         @rect = Omega::Rectangle.new(0, 0, 4, 4)
#         @damage = 1
#     end

#     def go_f4st()
#         @rect.x = self.x
#         @rect.y = self.y
#         super()
#     end

#     def copy_at(x, y)
#         $sounds["shot"].play(0.03)
#         bullet = EnemyNeedle.new(self.isEnemy)
#         bullet.x = x
#         bullet.y = y
#         return bullet
#     end

# end

# class Yoinky < Bullet

#     def initialize(isEnemy)
#         super("assets/images/enemy_yoink.png", 0, isEnemy, 70)
#         @rect = Omega::Rectangle.new(0, 0, 4, 4)
#         @scale = Omega::Vector2.new(1, 1)
#         @damage = 5
#     end

#     def go_f4st()
#         @speed -= (@speed - 25) * 0.01
#         @rect.x = self.x
#         @rect.y = self.y
#         super()
#     end

#     def copy_at(x, y)
#         $sounds["shot"].play(0.03)
#         bullet = EnemyYoinky.new(self.isEnemy)
#         bullet.x = x
#         bullet.y = y
#         return bullet
#     end

# end

# class FireBeam < Bullet

#     def initialize(isEnemy)
#         super("assets/images/fire_beam.png", 0, isEnemy, 50)
#         @rect = Omega::Rectangle.new(0, 0, 20, 20)
#         @scale = Omega::Vector2.new(1, 1)
#         @damage = 5
#     end

#     def go_f4st()
#         @scale.x += 0.05
#         @scale.y += 0.05
#         set_alpha(alpha - 8)
#         @rect.x = self.x
#         @rect.y = self.y
#         super()
#     end

#     def copy_at(x, y)
#         bullet = FireBeam.new(@isEnemy)
#         bullet.x = x
#         bullet.y = y
#         return bullet
#     end

#     def draw()
#         super()
#     end

# end

# class PlasmaBeam < Bullet

#     def initialize(isEnemy)
#         super("assets/images/ultra_lazor.png", 0, isEnemy, 50)
#         @rect = Omega::Rectangle.new(0, 0, 10, 10)
#         @scale = Omega::Vector2.new(0.5, 0.5)
#         @damage = 2
#     end

#     def go_f4st()
#         @scale.x += 0.05
#         @scale.y += 0.05
#         set_alpha(alpha - 8)
#         @rect.x = self.x
#         @rect.y = self.y
#         super()
#     end

#     def copy_at(x, y)
#         bullet = PlasmaBeam.new(self.isEnemy)
#         bullet.x = x
#         bullet.y = y
#         return bullet
#     end

#     def draw()
#         super()
#     end

# end

# class FireBase < Bullet

#     def initialize(isEnemy)
#         super("assets/images/fire_base.png", 0, @isEnemy, 50)
#         @rect = Omega::Rectangle.new(0, 0, 20, 20)
#         @scale = Omega::Vector2.new(1.5, 1.5)
#         @damage = 0
#     end

#     def go_f4st()
#         @scale.x += 0.05
#         @scale.y += 0.05
#         set_alpha(alpha - 4)
#         @angle += 2.5
#         super()
#     end

#     def copy_at(x, y)
#         bullet = FireBase.new(self.isEnemy)
#         bullet.x = x
#         bullet.y = y
#         return bullet
#     end

#     def draw()
#         super()
#     end

# end

# class UltraBomba < Bullet

#     attr_accessor :velocity

#     def initialize(isEnemy)
#         super("assets/images/ultra_bomba.png", 3, isEnemy, 150)
#         @rect = Omega::Rectangle.new(0, 0, 10, 10)
#         @scale = Omega::Vector2.new(1.5, 1.5)
#         @gravity = 9.8
#         @velocity = Omega::Vector2.new(0, 0)
#         @splod = UltraBullet.new(@isEnemy)
#         @damage = 10
#     end

#     def go_f4st()
#         if @lifetime < 0
#             die
#         end
#         @lifetime -= 1
#         @angle = Math::atan2(@velocity.y, @velocity.x)
#         self.x += @velocity.x
#         self.y += @velocity.y
#         @velocity.y += 0.2
#         if self.y >= Omega::height / $scale - 16
#             on_hit()
#         end
#     end

#     def on_hit()
#         tmp = nil
#         for i in 0...11
#             tmp = @splod.copy_at(self.x, self.y)
#             tmp.angle = i * 18 * -1
#             self.add_bullet(tmp)
#         end
#         die
#     end

#     def copy_at(x, y)
#         bullet = UltraBomba.new(self.isEnemy)
#         bullet.x = x
#         bullet.y = y
#         return bullet
#     end

#     def draw()
#         super()
#     end

# end

# class UltraHelixBase < Bullet

#     attr_accessor :velocity

#     def initialize(isEnemy)
#         super("assets/images/ultra_helix.png", 3, isEnemy, 150)
#         @rect = Omega::Rectangle.new(0, 0, 8, 8)
#         @scale = Omega::Vector2.new(1, 1)
#         @damage = 1
#     end

#     def go_f4st()
#         if @lifetime < 0
#             die
#         end
#         @lifetime -= 1
#         @rect.x = self.x - 4
#         @rect.y = self.y - 4
#     end

#     def on_hit()
#         die
#     end

#     def copy_at(x, y)
#         bullet = UltraHelixBase.new(self.isEnemy)
#         bullet.x = x
#         bullet.y = y
#         return bullet
#     end

#     def draw()
#         super()
#     end

# end

# class UltraHelix < Bullet

#     attr_accessor :helix

#     def initialize(isEnemy)
#         super("assets/images/ultra_helix.png", 5, isEnemy, 150)
#         @helix = []
#         @cycle = 0
#         @rect = Omega::Rectangle.new(0, 0, 0, 0)
#         @scale = Omega::Vector2.new(1.5, 1.5)
#         @damage = 1
#     end

#     def go_f4st()
#         if @lifetime < 0
#             die
#         end
#         @lifetime -= 1
#         self.x += @speed * Math::cos(Omega::to_rad(@angle))
#         self.y += @speed * Math::sin(Omega::to_rad(@angle))
#         @cycle += 5
#         if @cycle == 360
#             @cycle = 0
#         end
#         @helix[0].position = Omega::Vector3.new(self.x + 35 * Math::cos(Omega::to_rad(@cycle)), self.y + 35 * Math::sin(Omega::to_rad(@cycle)), 0) if @helix[0] != nil
#         @helix[1].position = Omega::Vector3.new(self.x - 35 * Math::cos(Omega::to_rad(@cycle)), self.y - 35 * Math::sin(Omega::to_rad(@cycle)), 0) if @helix[1] != nil
#     end

#     def on_hit(); end

#     def copy_at(x, y)
#         $sounds["shot"].play(0.3)
#         bullet = UltraHelix.new(self.isEnemy)
#         bullet.x = x
#         bullet.y = y
#         helix_1 = UltraHelixBase.new(self.isEnemy)
#         helix_2 = UltraHelixBase.new(self.isEnemy)
#         self.add_bullet(helix_1)
#         self.add_bullet(helix_2)
#         bullet.helix = [
#             helix_1,
#             helix_2
#         ]
#         return bullet
#     end

#     def draw()
#         @helix[0].draw() if @helix[0] != nil
#         @helix[1].draw() if @helix[1] != nil
#     end

# end
