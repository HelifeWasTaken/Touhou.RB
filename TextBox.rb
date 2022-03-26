class TextBox

  def initialize(text)

    @box = Omega::Sprite.new("./assets/images/dialog_box.png")
    @box.z = 10000001
    @box.set_scale(3.5, 2.25)
    @box.x = Omega.width / 2 - (320 * 3.5) / 2
    @box.y = 3

    @buffer         = text
    @current_buffer = ""

    @BUFFER_STARTX  = @box.x + 180
    @BUFFER_STARTY  = @box.y + 40

    @BUFFER_MAX_COL  = 80
    @BUFFER_MAX_LINE = 3

    @posx_buffer    = 0
    @posy_buffer    = 0

  end

  def set_y(y)
    @box.y = y
    @BUFFER_STARTY = y + 40
  end

  def is_buffer_full
    return @posy_buffer >= @BUFFER_MAX_LINE
  end

  def has_finished_to_write
    return @buffer.size() == 0
  end

  def update
    if self.is_buffer_full() == false and @buffer.size() > 0
      if @posx_buffer >= @BUFFER_MAX_COL
        @current_buffer += "\n"
        @posx_buffer = 0
        @posy_buffer += 1
      end
      @current_buffer += @buffer[0]
      @buffer = @buffer[1..@buffer.size()]
      @posx_buffer += 1
      $sounds["talk"].play(0.2) if Omega.frame_count() % 4 == 0
    end
  end

  def draw
    @box.draw()
    $font.draw_text(@current_buffer, @BUFFER_STARTX, @BUFFER_STARTY, 10000001, 0.6, 0.6, Gosu::Color.new(@box.alpha, 255, 255, 255))
  end

  def clear_current_buffer
    @current_buffer = ""
    @posx_buffer = 0
    @posy_buffer = 0
  end

  def finished
    return (@buffer.size() == 0 and @current_buffer.size() == 0)
  end

end

class TextBoxHandler

  def initialize
    @boxes = []
    @sounds = []
  end

  def play_current_sound
    if @sounds[0] != nil
      current_sound = @sounds[0]
      $sounds[current_sound.split("$")[1]].play()
    end
  end

  def set_y(y)
    @boxes.each do |box|
      box.set_y(y)
    end
  end

  def add_text(full_text)
    full_text.split("|").each do |text|
      real_text = []
      sound = nil
      text.split(" ").each do |text_elem|
        if text_elem[0] == '$'
          sound = text_elem
        else
          real_text.push(text_elem)
        end
      end
      @sounds.push(sound)
      @boxes.push(TextBox.new(real_text.join(" ")))
      self.play_current_sound()
    end
  end

  def update
    if self.finished()
      return
    end
    if @boxes[0].finished()
      @boxes  = @boxes[1..@boxes.size()]
      @sounds = @sounds[1..@sounds.size()]
      self.play_current_sound()
      return
    end
    if @boxes[0].is_buffer_full() or @boxes[0].has_finished_to_write()
      if Game::is_just_pressed_ok
        @boxes[0].clear_current_buffer()
      end
    else
      @boxes[0].update()
    end
  end

  def finished
    return @boxes.size() == 0
  end

  def draw
    if self.finished()
      return
    end
    @boxes[0].draw()
  end

end
