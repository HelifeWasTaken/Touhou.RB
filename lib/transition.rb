module Omega

    module TransitionState
        TNONE = 0
        TBEGIN = 1
        TEND = 2
    end

    class Transition
        attr_accessor :state, :z

        def initialize(&block)
            # Initializing the default state
            @state = Omega::TransitionState::TNONE
            # Useful value to know when the transition ends
            @finished = false
            # Keep track of the Z order of the transition
            @z = 10_000
            # Save the callback
            @callback = block
        end

        def launch
            # Launch the transition
            @state = Omega::TransitionState::TBEGIN
        end

        def callback
            # Call the actions sent by the user
            @callback.call()
        end

        def update; end # To be overriden

        def draw; end   # To be overriden

        def finished?
            @finished
        end

        def stop
            @finished = true
        end

        protected

        def finished=(x)
            @finished = x
        end
    end

    class FadeTransition < Transition
        def initialize(speed = 5, color = Omega::Color::BLACK)
            # Initializing the state of the transition
            super()
            # Set some initial values
            @speed = speed
            # Set default color to black
            @color = color
            @color.alpha = 0
        end

        def update
            if @state == Omega::TransitionState::TBEGIN
                # Update fade out
                @color._alpha = (@color.alpha + @speed).clamp(0, 255)
                if @color.alpha >= 255
                    callback()
                    @state = Omega::TransitionState::TEND
                end
            elsif @state == Omega::TransitionState::TEND
                # Update the fade in
                @color._alpha = (@color.alpha - @speed).clamp(0, 255)
                if @color.alpha == 0
                    # The transition is finished
                    self.finished = true
                end
            end
        end

        def draw
            # Draw the transition quad
            Gosu.draw_rect(0, 0, Omega.width, Omega.height, @color, @z)
        end

        def alpha=(alpha)
            @color._alpha = alpha
        end

        def alpha
            return @color.alpha
        end
    end

end