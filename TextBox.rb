class TextBox

  def initialize(text, on_left)

    @box = Omega::Sprite.new("./assets/images/dialog_box.png")
    @box.z = 10000001
    @box.set_scale(3.5, 2.25)
    @box.x = Omega.width / 2 - (320 * 3.5) / 2
    @box.y = Omega.height - @box.height * 2.5

    @on_left = on_left

    @buffer         = text
    @current_buffer = ""

    @BUFFER_STARTX  = @box.x + 80
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

  def is_right
    return @on_left
  end

end

$_BOX_OFFSET_CHARA = 50
$_BOX_SPEED_CHARA = 15

class TextBoxHandler

  def initialize
    @boxes = []
    @sounds = []
    @full_text = []
    @current_index = 0
  end

  def play_current_sound
    if @sounds[@current_index] != nil
      current_sound = @sounds[@current_index]
      $sounds[current_sound.split("$")[1]].play()
    end
  end

  def set_y(y)
    @boxes.each do |box|
      box.set_y(y)
    end
  end

  def set_left_character(chara)
    @left_character = Omega::Sprite.new(chara)
    @left_character.y = Omega.height / 2 - @left_character.height / 2 - 60
    @left_character.x = -@left_character.width
  end

  def set_right_character(chara)
    @right_character = Omega::Sprite.new(chara)
    @right_character.y = Omega.height / 2 - @right_character.height / 2 - 60
    @right_character.x = Omega.width
  end

  def set_left_chara_should_go
      dest = 20
      if not is_right_turn
        dest += $_BOX_OFFSET_CHARA
      end
      if @left_character.nil?
        return
      end
      if @left_character.x > dest
        @left_character.x -= $_BOX_SPEED_CHARA
        if @left_character.x < dest
          @left_character.x = dest
        end
      elsif @left_character.x < dest
        @left_character.x += $_BOX_SPEED_CHARA
        if @left_character.x > dest
          @left_character.x = dest
        end
      else
        return true
      end
    return true
  end

  def set_right_chara_should_go
    dest = Omega.width - @right_character.width - 30
    if is_right_turn
      dest -= $_BOX_OFFSET_CHARA
    end
    if @right_character.x > dest
      @right_character.x -= $_BOX_SPEED_CHARA
      if @right_character.x < dest
        @right_character.x = dest
      end
    elsif @right_character.x < dest
      @right_character.x += $_BOX_SPEED_CHARA
      if @right_character.x > dest
        @right_character.x = dest
      end
    else
      return true
    end
    return true
  end

  def add_text(full_text, is_right)
    if is_right
      @full_text.push("right|" + full_text)
    else
      @full_text.push("left|" + full_text)
    end
  end

  def start
    added_left_once = false
    added_right_once = false

    @full_text.each do |partext|
      ctext = partext.split("|")
      isLeft = ctext[0] == "left"
      ctext.delete_at(0)

      ctext.each do |text|
        real_text = []
        sound = nil

        text.split(" ").each do |text_elem|
          if text_elem[@current_index] == '$'
            sound = text_elem
          else
            real_text.push(text_elem)
          end
        end
        @sounds.push(sound)
        if isLeft
          @boxes.push(TextBox.new(real_text.join(" "), true))
          added_left_once = true
        else
          @boxes.push(TextBox.new(real_text.join(" "), false))
          added_right_once = true
        end
        self.play_current_sound()
      end
    end
  end

  def update
    if self.finished()
      return
    end
    if set_left_chara_should_go && set_right_chara_should_go == false
      return
    end
    if @boxes[@current_index].finished()
      self.play_current_sound()
      @current_index += 1
      return
    end
    if @boxes[@current_index].is_buffer_full() or @boxes[@current_index].has_finished_to_write()
      if Game::is_just_pressed_ok
        @boxes[@current_index].clear_current_buffer()
        if @boxes[@current_index].has_finished_to_write
          @current_index += 1
        end
      end
    else
      @boxes[@current_index].update()
    end
  end

  def is_right_turn
    return @boxes[@current_index].is_right
  end

  def finished
    return @boxes.size() == @current_index
  end

  def draw
    if not finished
      @boxes[@current_index].draw
      if @boxes[@current_index].is_right
          if not @right_character.nil?
              @right_character.color = Omega::Color.new(0xff_ffffff)
          end
          if not @left_character.nil?
              @left_character.color  = Omega::Color.new(0xff_808080)
          end
      else
          if not @right_character.nil?
              @right_character.color = Omega::Color.new(0xff_808080)
          end
          if not @left_character.nil?
              @left_character.color  = Omega::Color.new(0xff_ffffff)
          end
      end
      if @left_character != nil
          @left_character.draw
      end
      if @right_character != nil
          @right_character.draw
      end
    end
  end

  # def clear
  #   self = TextBoxHandler.new
  # end

end
