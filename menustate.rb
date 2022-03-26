$cirno_talk = "./assets/talk/cirno_talk.png"

class MenuState < Omega::State

    def load
        @timer = 0
      @t = TextBoxHandler.new
      @t.set_left_character($cirno_talk)
      @t.set_right_character($cirno_talk)

      @t.add_text("You dare opposing me", true)
      @t.add_text("I am the right character", false)
      @t.add_text("I am the left character but it's my second dialog", true)

      #@t.add_text("You dare opposing me", false)
      @t.start()
    end

    def update
      @t.update
    end

    def draw
        $camera.draw do
        end
        @t.draw
    end

end
