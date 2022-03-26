class TouhouCharacter

  attr_accessor :position

  def initialize(sp)
    @complete_image = Gosu::Image.new(sp)
    @frames = [@complete_image.subimage(0, 0, 48, 48)]
    @rect = @frames[0]
    @max_index = 6
    @position = Omega::Vector2.new(10, 10)
    @timer = 0

    y = 0
    for i in 1...@max_index
      y += 48
      @frames.push(@complete_image.subimage(0, y, 48, 48))
    end

    @current_index = 0
    @scale = 2
  end

  def update
    if @timer > 3
      moved = false
      if Omega::pressed(Gosu::KB_A)
        if @current_index != -5
          @current_index -= 1
          moved = true
        end
      end
      if Omega::pressed(Gosu::KB_D)
        if @current_index != 5
          @current_index += 1
          moved = true
        end
      end
      if moved == false
        if @current_index < 0
          if @current_index < -2
            @current_index = -2
          else
            @current_index += 1
          end
        elsif @current_index > 0
          if @current_index > 2
            @current_index = 2
          else
            @current_index -= 1
          end
        end
      end
      @timer = 0
    end
    @timer += 1
  end

  def draw
    if @current_index > 0
      index = @max_index - (@current_index % @max_index)
      @frames[index].draw(@position.x + @frames[index].width * @scale, @position.y, 10000001, -@scale, @scale)
    else
      @frames[@current_index].draw(@position.x, @position.y, 1000001, @scale, @scale)
    end
  end

end

class Player < TouhouCharacter

    def initialize
        super("assets/textures/character/player.png")

        @max_health = 20;
        @health = 20;

        @position.x = 10
        @position.y = 10

        @shooter = BladeStorm.new(false)
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
        super
    end

    def draw
        @shooter.draw
        super
    end
end
