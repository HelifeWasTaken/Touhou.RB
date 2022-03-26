# Omega 3D Engine - by D3nX
# Under MIT Licence
# "The Omega Engine is a Gosu based game framework that claim
# "to be fully open source and help everyone to developp faster
# and more efficiently game in ruby"
# Build 0.1

# Importing opengl & glu
require 'opengl'
require 'glu'

OpenGL.load_lib
GLU.load_lib

include OpenGL, GLU

module Omega
    require_relative "map3d"
    require_relative "cube"
    module L3D

        Light = Struct.new(:x, :y, :z, :red, :green, :blue)

        def L3D.render3d(gl_z = 0, near = 1, far = 1000, fovy = 45, use_display_list = false)
            Gosu::gl(gl_z) do


                glEnable(GL_DEPTH_TEST)
                glEnable(GL_TEXTURE_2D)

                glMatrixMode(GL_PROJECTION)
                glLoadIdentity
                gluPerspective(fovy, Omega.width.to_f / Omega.height.to_f, near, far)

                glEnable(GL_BLEND)
                # glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

                glMatrixMode(GL_MODELVIEW)
                glLoadIdentity

                glClearColor(0.0, 0.0, 0.0, 0.0)
                glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

                
                yield
            end
        end

        class Camera3D
            attr_accessor :position, :look

            def initialize
                @position = Omega::Vector3.new(0, 0, 0)
                @look = Omega::Vector3.new(0, 0, 0)
            end

            def look_at(x, y, z)
                @look = Omega::Vector3.new(x, y, z)
            end

            def act
                gluLookAt(@position.x, 
                          @position.y,
                          @position.z,
                          @look.x,
                          @look.y,
                          @look.z,
                          0, 1, 0)
            end

            def angle_z
                return Gosu.angle(@position.x, @position.z, @look.x, @look.z)
            end

        end

        class Texture3D
            attr_accessor :images, :points, :position, :current_frame, :frame_speed, :width, :height, :color
            attr_accessor :face_camera, :origin
            attr_accessor :render_color
            def initialize(path, scale = 0, width = -1, height = -1)

                @@static_images ||= {}

                if width == -1 or height == -1
                    if not @@static_images.include?(path)
                        if path.is_a? String
                            @@static_images[path] = [Gosu::Image.new(path, :tileable => true)]
                        elsif path.is_a? Gosu::Image
                            @@static_images[path] = [path]
                        end
                    end
                    @images = @@static_images[path]
                    @width = @images[0].width
                    @height = @images[0].height
                else
                    if not @@static_images.include?(path)
                        @@static_images[path] = Gosu::Image.load_tiles(path, width, height)
                    end
                    @images = @@static_images[path]
                    @width = width
                    @height = height
                end

                @current_frame = 0
                @frame_speed = 0.1

                @scale = scale

                @color = Gosu::Color::WHITE

                @position = Omega::Vector3.new(0, 0, 0)

                @origin = Omega::Vector3.new(0.0, 0, 0)

                @points = Array.new(4) { Omega::Vector3.new(0, 0, 0) }

                @pause = false

                @render_color = true

                @animations = {}
                @current_animation = nil
            end

            def draw(cam_angle = nil)
                if not @pause
                    if not @current_animation
                        @current_frame += @frame_speed
                        @current_frame %= @images.size

                        image = @images[@current_frame.to_i % @images.size]

                        l, r, t, b = image.gl_tex_info.left, image.gl_tex_info.right, image.gl_tex_info.top, image.gl_tex_info.bottom
                        glBindTexture(GL_TEXTURE_2D, image.gl_tex_info.tex_name)
                    else
                        @current_frame += @frame_speed
                        @current_frame %= @animations[@current_animation].size

                        image = @images[@animations[@current_animation][@current_frame.to_i] % @images.size]

                        l, r, t, b = image.gl_tex_info.left, image.gl_tex_info.right, image.gl_tex_info.top, image.gl_tex_info.bottom
                        glBindTexture(GL_TEXTURE_2D, image.gl_tex_info.tex_name)
                    end
                end

                glPushMatrix()
                    cx = @width * @scale * @origin.x
                    cy = @height * @scale * @origin.y
                    cz = @height * @scale * @origin.z

                    glTranslatef(@position.x+cx, @position.y+cx, @position.z+cx)
                    # glRotatef(-cam_angle, 1, 0, 0) if cam_angle
                    glRotatef(cam_angle, 0, 1, 0) if cam_angle
                    glTranslatef(-cx, -cy, -cz)
                    
                    glScalef(@width, @height, 1)

                    origin = Omega::Vector3.new((@origin.x * @scale), (@origin.y * @scale), (@origin.z * @scale))

                    glBegin(GL_QUADS)
                        glTexCoord2d(l, t)
                        glColor4ub(@color.red, @color.green, @color.blue, 255) if @render_color
                        glVertex3f(@points[0].x, @points[0].y, @points[0].z)
                        glTexCoord2d(l, b)
                        glColor4ub(@color.red, @color.green, @color.blue, 255) if @render_color
                        glVertex3f(@points[1].x, @points[1].y, @points[1].z)
                        glTexCoord2d(r, b)
                        glColor4ub(@color.red, @color.green, @color.blue, 255) if @render_color
                        glVertex3f(@points[2].x, @points[2].y, @points[2].z)
                        glTexCoord2d(r, t)
                        glColor4ub(@color.red, @color.green, @color.blue, 255) if @render_color
                        glVertex3f(@points[3].x, @points[3].y, @points[3].z)
                    glEnd()

                glPopMatrix()
            end

            def add_animation(id, array)
                @animations[id] = array
            end
    
            def play_animation(id)
                @current_frame = 0
                @current_animation = id
            end
    
            def stop
                @current_frame = 0
                @current_animation = nil
            end
    
            def pause
                @pause = true
            end
    
            def resume
                @pause = false
            end
    
            def frame
                return @animations[@current_animation][@current_frame.to_i]
            end
        end

    end
end