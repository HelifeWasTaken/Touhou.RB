class TouhouCharacter

  attr_accessor :position, :box

  def initialize(sp, max_frames, scale, size_x, size_y)
    @complete_image = Gosu::Image.new(sp)
    @frames = [@complete_image.subimage(0, 0, size_x, size_y)]
    @max_index = max_frames
    @position = Omega::Vector2.new(10, 10)
    @timer = 0
    @box = Omega::Rectangle.new(0, 0, size_x / 4, size_y / 4)

    y = 0
    for i in 1...@max_index
      y += size_y
      @frames.push(@complete_image.subimage(0, y, size_x, size_y))
    end

    @current_index = 0
    @scale = scale
  end

  def update
    @box.x = @position.x - @box.width / 2
    @box.y = @position.y - @box.height / 2
    if @timer > 3
      moved = false
      if Omega::pressed(Gosu::KB_A)
        if @current_index != -@max_index + 1
          @current_index -= 1
          moved = true
        end
      end
      if Omega::pressed(Gosu::KB_D)
        if @current_index != @max_index - 1
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
      @frames[index].draw(@position.x + @frames[@current_index].width * @scale - (@frames[@current_index].width / 2) * @scale, @position.y - (@frames[@current_index].height / 2) * @scale, 0, -@scale, @scale)
    else
      @frames[@current_index].draw(@position.x - (@frames[@current_index].width / 2) * @scale, @position.y - (@frames[@current_index].height / 2) * @scale, 0, @scale, @scale)
    end
    # @box.draw
  end

end

class Player < TouhouCharacter

    attr_accessor :health, :max_health

    def initialize
        super("assets/textures/character/player.png", 6, 1.5, 48, 48)

        @max_health = 80;
        @health = @max_health;

        @position.x = 10
        @position.y = 10
        @shooter = PeasShooter.new(false)
    end

    def controller
        if Omega::pressed(Gosu::KB_W)
          if not @position.y <= 8
            @position.y -= 5
          end
        end
        if Omega::pressed(Gosu::KB_A)
          if not @position.x <= 8
            @position.x -= 5
          end
        end
        if Omega::pressed(Gosu::KB_S)
          if not @position.y >= Omega.height - 8
            @position.y += 5
          end
        end
        if Omega::pressed(Gosu::KB_D)
          if not @position.x >= Omega.width - 8
            @position.x += 5
          end
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
        if not $stop and not $in_cinematic
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

    def damage
      @health -= 1
    end

    def is_dead?
      return @health <= 0.0
    end

end
