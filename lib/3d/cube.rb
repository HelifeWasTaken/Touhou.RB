module Omega

    module L3D

        class Cube

            attr_reader :scale, :width, :height, :length, :position
            attr_accessor :visible_faces, :render_color

            def initialize(tex_path)

                if tex_path.is_a? String
                    @textures = Array.new(6) { Omega::L3D::Texture3D.new(tex_path) }
                else
                    @textures = []
                    tex_path.each do |t|
                        @textures << Omega::L3D::Texture3D.new(t)
                    end
                end

                @width =  @textures[0].width
                @height = @textures[0].height
                @length = @textures[0].height

                @position = Omega::Vector3.new(0, 0, 0)
                @scale = Omega::Vector3.new(1, 1, 1)

                @visible_faces = [
                    true,
                    true,
                    true,
                    true,
                    true,
                    true
                ]

                @render_color = true

                update(@scale, @position)
            end

            def update(scale, position)

                @position = position
                @scale = scale

                # Front face
                @textures[0].points[0] = Omega::Vector3.new(0, scale.y, 0)
                @textures[0].points[1] = Omega::Vector3.new(0, 0, 0)
                @textures[0].points[2] = Omega::Vector3.new(scale.x, 0, 0)
                @textures[0].points[3] = Omega::Vector3.new(scale.x, scale.y, 0)

                # Back face
                @textures[1].points[0] = Omega::Vector3.new(0, scale.y, @length * scale.z)
                @textures[1].points[1] = Omega::Vector3.new(0, 0, @length * scale.z)
                @textures[1].points[2] = Omega::Vector3.new(scale.x, 0, @length * scale.z)
                @textures[1].points[3] = Omega::Vector3.new(scale.x, scale.y, @length * scale.z)

                # Left face
                @textures[2].points[0] = Omega::Vector3.new(0, scale.y, 0)
                @textures[2].points[1] = Omega::Vector3.new(0, 0, 0)
                @textures[2].points[2] = Omega::Vector3.new(0, 0, @length * scale.z)
                @textures[2].points[3] = Omega::Vector3.new(0, scale.y, @length * scale.z)

                # Right face
                @textures[3].points[0] = Omega::Vector3.new(scale.x, scale.y, 0)
                @textures[3].points[1] = Omega::Vector3.new(scale.x, 0, 0)
                @textures[3].points[2] = Omega::Vector3.new(scale.x, 0, @length * scale.z)
                @textures[3].points[3] = Omega::Vector3.new(scale.x, scale.y, @length * scale.z)

                # Up face
                @textures[4].points[0] = Omega::Vector3.new(0, scale.y, @length * scale.z)
                @textures[4].points[1] = Omega::Vector3.new(0, scale.y, 0)
                @textures[4].points[2] = Omega::Vector3.new(scale.x, scale.y, 0)
                @textures[4].points[3] = Omega::Vector3.new(scale.x, scale.y, @length * scale.z)

                # Down face
                @textures[5].points[0] = Omega::Vector3.new(0, 0, @length * scale.z)
                @textures[5].points[1] = Omega::Vector3.new(0, 0, 0)
                @textures[5].points[2] = Omega::Vector3.new(scale.x, 0, 0)
                @textures[5].points[3] = Omega::Vector3.new(scale.x, 0, @length * scale.z)

                @textures.each { |t| t.position = position }
            end

            def update_color(r, g, b, a)
                @textures.each do |t|
                    t.color = Gosu::Color.new(a, r, g, b)
                end
            end

            def draw
                i = 0
                @textures.each do |t|
                    t.render_color = @render_color
                    t.draw() if @visible_faces[i]
                    i += 1
                end
            end

            def set_size(size)
                scale = Omega::Vector3.new((size.x.to_f/@width), (size.y.to_f/@height), (size.z.to_f/@length))
                update(scale, @position)
            end

        end

    end

end