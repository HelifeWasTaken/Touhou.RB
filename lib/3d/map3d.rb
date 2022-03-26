module Omega

    module L3D
        class Map3D
            attr_accessor :tile_width, :tile_height, :width, :height, :player_start_position, :map, :dist
        
            def initialize(map_path, tileset_path, tile_size)
                @map = []
        
                data = File.read(map_path)
                x = 0
                y = 0
                data.split("\n") do |line|
                    @map << []
                    line.split(",") do |id|
                        @map[-1] << id.to_i
        
                        if id.to_i == 2
                            @player_start_position = Vector2.new(x, y)
                        end
        
                        x += 1
                    end
                    y += 1
                    x = 0
                end
        
                @tiles ||= Gosu::Image.load_tiles(tileset_path, 32, 32, retro: true)
                @tiles_id = []
                @tiles.each do |tile|
                    @tiles_id << tile.gl_tex_info.tex_name
                end
        
                @floor_index = 1
                @ceiling_index = 6
                @wall_index = 0
        
                @tile_size = tile_size

                @tile_width = tile_size
                @tile_height = tile_size
        
                @width = @map[0].size
                @height = @map.size
        
                drawing_dist = 250

                # Ground
                @ground = Omega::L3D::Texture3D.new("assets/pavedground.png")
                @ground.points[0] = Omega::Vector3.new(0, 0, 32)
                @ground.points[1] = Omega::Vector3.new(0, 0, 0)
                @ground.points[2] = Omega::Vector3.new(32.0/@ground.width, 0, 0)
                @ground.points[3] = Omega::Vector3.new(32.0/@ground.width, 0, 32)

                # Some objects
                @house = Omega::L3D::Cube.new("assets/house.png")
                @house.update(Omega::Vector3.new(0.1, 0.1, 0.1), Omega::Vector3.new(0, 1, 0))
                @house.update_color(5, 5, 15, 255)

                @house.visible_faces = [
                    true,
                    true,
                    true,
                    true,
                    false,
                    false
                ]

                @building = Omega::L3D::Cube.new("assets/building.jpg")
                @building.update(Omega::Vector3.new(0.1, 2.5, 0.1), Omega::Vector3.new(0, 1, 0))
                @building.update_color(5, 5, 15, 255)

                @building.visible_faces = [
                    true,
                    true,
                    true,
                    true,
                    false,
                    false
                ]

                @chunks = []
                @chunks_positions = []
            end

            def generate_chunk(chunk_width, chunk_height)
                chunk_x = 0
                chunk_y = 0

                while chunk_y < @height
                    # Draw the chunk
                    @chunks << glGenLists(1)
                    glNewList(@chunks[-1], GL_COMPILE)
                        last_id = -1

                        for x in chunk_x...(chunk_x + chunk_width).clamp(0, @width)
                            for y in chunk_y...(chunk_y + chunk_height).clamp(0, @height)
                                c = 1

                                if @map[y][x] == -1
                                    @ground.render_color = false
                                    @ground.color = Gosu::Color.new(255, c * 255, c * 255, c * 255)
                                    @ground.position = Omega::Vector3.new(x * @tile_width, 0, y * @tile_height)
                                    @ground.draw()

                                    last_id = -1
                                end

                                next if @map[y][x] == -1

                                if @map[y][x] == 0
                                    $house.render_color = false
                                    $house.update(Omega::Vector3.new(0.08, 0.08, 0.08), Omega::Vector3.new(x * @tile_width, 0, y * @tile_height))
                                    $house.set_size(Omega::Vector3.new(32, 32, 32))
                                    $house.update_color(c * 255, c * 255, c * 255, 255)
                                    $house.draw()
                                    last_id = -1
                                    next
                                elsif @map[y][x] == 13
                                    $building.render_color = false
                                    $building.update(Omega::Vector3.new(1, 1, 1), Omega::Vector3.new(x * @tile_width, 0, y * @tile_height))
                                    $building.set_size(Omega::Vector3.new(32, 150, 32))
                                    $building.update_color(c * 255, c * 255, c * 255, 255)
                                    $building.draw()
                                    last_id = -1
                                    next
                                end

                                puts "error" if not @tiles[@map[y][x]]
                                l, r, t, b = @tiles[@map[y][x]].gl_tex_info.left, @tiles[@map[y][x]].gl_tex_info.right, @tiles[@map[y][x]].gl_tex_info.top, @tiles[@map[y][x]].gl_tex_info.bottom

                                if @tiles_id[@map[y][x]] != last_id
                                    glBindTexture(GL_TEXTURE_2D, @tiles_id[@map[y][x]])
                                    last_id = @tiles_id[@map[y][x]]
                                end

                                glBegin(GL_QUADS)
                                glTexCoord2d(l, t);
                                # glColor3f(c, c, c)
                                glVertex3f(x * @tile_width, 0, y * @tile_height)
                                glTexCoord2d(l, b);
                                # glColor3f(c, c, c)
                                glVertex3f(x * @tile_width, 0, y * @tile_height + @tile_height)
                                glTexCoord2d(r, b);
                                # glColor3f(c, c, c)
                                glVertex3f(x * @tile_width + @tile_width, 0, y * @tile_height + @tile_height)
                                glTexCoord2d(r, t);
                                # glColor3f(c, c, c)
                                glVertex3f(x * @tile_width + @tile_width, 0, y * @tile_height) 
                                glEnd()
                            end
                        end
                    glEndList()

                    # Add the position to chunk position
                    @chunks_positions << Omega::Vector2.new(chunk_x * @tile_width + (chunk_width / 2) * @tile_width, chunk_y * @tile_height + (chunk_height / 2) * @tile_height)

                    # Go the next chunk
                    chunk_x += chunk_width
                    if chunk_x >= @width # and chunk_y + chunk_height < @height
                        chunk_y += chunk_height
                        chunk_x = 0
                    end
                end
            end

            def draw_chunks(camera_position = nil, camera_angle = 0, drawing_dist = 1000, lightning = 1.0)
                i = 0
                @chunks.each do |chunk|
                    if not camera_position
                        glColor4f(1, 1, 1, 1)
                        glCallList(chunk)
                    else
                        # We calculate the distance between us and the chunk
                        dist = Omega::distance(Omega::Vector2.new(camera_position.x, camera_position.z), @chunks_positions[i])

                        # If the distance is okay, we check if the angle is good
                        # and if the angle is good (=> We can actually see it)
                        # we draw it.
                        if dist < drawing_dist
                            angle = Gosu.angle(camera_position.x, camera_position.z, @chunks_positions[i].x, @chunks_positions[i].y)

                            c = 1.0 - (1.0 / (drawing_dist*0.5)) * (dist*0.5)
                            a = 1.0
                            if c < 0.5
                                a = (1.0 / 0.5) * c
                            end
                            glColor4f(c * lightning, c * lightning, c * lightning, a)

                            # puts (angle - camera_angle)%360 if i == 0
                            glCallList(chunk) if a > 0.05 # if (angle - camera_angle - 90).abs % 360 < 60
                        end
                    end

                    i += 1
                end
            end
        
            def draw(light, draw_full_map = false, drawing_dist = 500, enable_ground = false, look = Omega::Vector3.new(0, 0, 0))
                last_id = -1

                # for x in (light.x.to_i/@tile_size - drawing_dist/@tile_size).to_i.clamp(0, @width)...(light.x.to_i/@tile_size + drawing_dist/@tile_size).to_i.clamp(0, @width)
                # for y in (light.y.to_i/@tile_size - drawing_dist/@tile_size).to_i.clamp(0, @height)...(light.y.to_i/@tile_size + drawing_dist/@tile_size).to_i.clamp(0, @height)

                base_angle = Math.atan2((look.x - 0), (look.z - 0)) * 180/Math::PI
                min_angle = base_angle - 45
                max_angle = base_angle + 90
        
                if draw_full_map

                    for x in 0...@width
                        for y in 0...@height

                            next if @map[y][x] == -1

                            c = (1.0 - ((1.0 / drawing_dist) * Gosu.distance(light.x, light.y, x * @tile_width, y * @tile_height))).clamp(0, 1)

                            if @map[y][x] == 0
                                @house.update(Omega::Vector3.new(1, 1, 1), Omega::Vector3.new(x * @tile_width + (@tile_width - @house.width) / 2, 0, y * @tile_height + (@tile_height - @house.height)/2))
                                @house.update_color(c * light.red, c * light.green, c * light.blue, 255)
                                @house.draw()
                                last_id = -1
                                next
                            elsif @map[y][x] == 13
                                @building.update(Omega::Vector3.new(1, 1, 1), Omega::Vector3.new(x * @tile_width, 0, y * @tile_height))
                                @building.update_color(c * light.red, c * light.green, c * light.blue, 255)
                                @building.draw()
                                last_id = -1
                                next
                            end

                            l, r, t, b = @tiles[@map[y][x]].gl_tex_info.left, @tiles[@map[y][x]].gl_tex_info.right, @tiles[@map[y][x]].gl_tex_info.top, @tiles[@map[y][x]].gl_tex_info.bottom

                            if @tiles_id[@map[y][x]] != last_id
                                glBindTexture(GL_TEXTURE_2D, @tiles_id[@map[y][x]])
                                last_id = @tiles_id[@map[y][x]]
                            end

                            glBegin(GL_QUADS)
                            glTexCoord2d(l, t);
                            glColor3f(c, c, c)
                            glVertex3f(x * @tile_width, 0, y * @tile_height)
                            glTexCoord2d(l, b);
                            glColor3f(c, c, c)
                            glVertex3f(x * @tile_width, 0, y * @tile_height + @tile_height)
                            glTexCoord2d(r, b);
                            glColor3f(c, c, c)
                            glVertex3f(x * @tile_width + @tile_width, 0, y * @tile_height + @tile_height)
                            glTexCoord2d(r, t);
                            glColor3f(c, c, c)
                            glVertex3f(x * @tile_width + @tile_width, 0, y * @tile_height) 
                            glEnd()
                        end
                    end
                else
                    for x in (light.x.to_i/@tile_size - drawing_dist/@tile_size).to_i.clamp(0, @width)...(light.x.to_i/@tile_size + drawing_dist/@tile_size).to_i.clamp(0, @width)
                        for y in (light.y.to_i/@tile_size - drawing_dist/@tile_size).to_i.clamp(0, @height)...(light.y.to_i/@tile_size + drawing_dist/@tile_size).to_i.clamp(0, @height)

                            # angle = Math.atan2((look.x - x * @tile_width), (look.z - y * @tile_height)) * 180/Math::PI
                            
                            # next if angle > max_angle or angle < min_angle

                            d = Gosu.distance(light.x, light.y, x * @tile_width, y * @tile_height)

                            c = (1.0 - ((1.0 / drawing_dist) * d)).clamp(0, 1)

                            @ground.color = Gosu::Color.new(255, c * 255, c * 255, c * 255)
                            @ground.position = Omega::Vector3.new(x * @tile_width, 0, y * @tile_height) if @map[y][x] == -1
                            @ground.draw()

                            last_id = -1
    
                            next if @map[y][x] == -1

                            if @map[y][x] == 0
                                $house.update(Omega::Vector3.new(0.08, 0.08, 0.08), Omega::Vector3.new(x * @tile_width, 0, y * @tile_height))
                                $house.set_size(Omega::Vector3.new(32, 32, 32))
                                $house.update_color(c * light.red, c * light.green, c * light.blue, 255)
                                $house.draw()
                                last_id = -1
                                next
                            elsif @map[y][x] == 13
                                $building.update(Omega::Vector3.new(1, 1, 1), Omega::Vector3.new(x * @tile_width, 0, y * @tile_height))
                                $building.set_size(Omega::Vector3.new(32, 150, 32))
                                $building.update_color(c * light.red, c * light.green, c * light.blue, 255)
                                $building.draw()
                                last_id = -1
                                next
                            end
    
                            l, r, t, b = @tiles[@map[y][x]].gl_tex_info.left, @tiles[@map[y][x]].gl_tex_info.right, @tiles[@map[y][x]].gl_tex_info.top, @tiles[@map[y][x]].gl_tex_info.bottom
    
                            if @tiles_id[@map[y][x]] != last_id
                                glBindTexture(GL_TEXTURE_2D, @tiles_id[@map[y][x]])
                                last_id = @tiles_id[@map[y][x]]
                            end
    
                            if d < drawing_dist*2
    
                                glBegin(GL_QUADS)
                                glTexCoord2d(l, t);
                                glColor3f(c, c, c)
                                glVertex3f(x * @tile_width, 0, y * @tile_height)
                                glTexCoord2d(l, b);
                                glColor3f(c, c, c)
                                glVertex3f(x * @tile_width, 0, y * @tile_height + @tile_height)
                                glTexCoord2d(r, b);
                                glColor3f(c, c, c)
                                glVertex3f(x * @tile_width + @tile_width, 0, y * @tile_height + @tile_height)
                                glTexCoord2d(r, t);
                                glColor3f(c, c, c)
                                glVertex3f(x * @tile_width + @tile_width, 0, y * @tile_height) 
                                glEnd()
                            end
                        end
                    end
                end
            end



        end
    end
end