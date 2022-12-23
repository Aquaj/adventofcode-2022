require_relative 'common'

class Day22 < AdventDay
  EXPECTED_RESULTS = { 1 => 6032, 2 => 5031 }

  class Sheet < Grid
    OUT = ' '
    WALL = '#'
    FREE = '.'

    attr_reader :up_sheet, :left_sheet, :right_sheet, :down_sheet

    def neighbor_sheets
      {
        up: up_sheet,
        down: down_sheet,
        left: left_sheet,
        right: right_sheet,
      }
    end

    def up_sheet=(sheet)
      return if @up_sheet == sheet
      @up_sheet = sheet
    end

    def left_sheet=(sheet)
      return if @left_sheet == sheet
      @left_sheet = sheet
    end

    def right_sheet=(sheet)
      return if @right_sheet == sheet
      @right_sheet = sheet
    end

    def down_sheet=(sheet)
      return if @down_sheet == sheet
      @down_sheet = sheet
    end

    def up(x,y)
      new_y = (y - 1) % self.height
      new_y = (new_y - 1) % self.height while out_of_bounds?(x, new_y)
      return nil if self[x,new_y] == WALL
      [x,new_y]
    end

    def down(x,y)
      new_y = (y + 1) % self.height
      new_y = (new_y + 1) % self.height while out_of_bounds?(x, new_y)
      return nil if self[x,new_y] == WALL
      [x,new_y]
    end

    def left(x,y)
      new_x = (x - 1) % self.width
      new_x = (new_x - 1) % self.width while out_of_bounds?(new_x, y)
      return nil if self[new_x,y] == WALL
      [new_x,y]
    end

    def right(x,y)
      new_x = (x + 1) % self.width
      new_x = (new_x + 1) % self.width while out_of_bounds?(new_x, y)
      return nil if self[new_x,y] == WALL
      [new_x,y]
    end

    def out_of_bounds?(x,y)
      super || self[y][x] == OUT
    end

    def turn_to_sheets(size:)
      localized = self.to_a.map.with_index { |r,y| r.map.with_index { |c,x| [x,y] } }
      localized.each_slice(size).map.with_index do |(first, *rows)|
        first.zip(*rows).each_slice(size).map.with_index do |(head, *cols)|
          sheet = head.zip(*cols)
          sheet.flatten(1).none? { |v| self[*v] } ? nil : self.class.new(sheet)
        end
      end
    end
  end

  MOVES = {
    up:    Vector[ 0,  1,  1],
    down:  Vector[ 0,  1, -1],
    left:  Vector[-1,  1,  0],
    right: Vector[ 1,  1,  0],
  }
  ROTATIONS = {
    up:    Matrix[[1,  0,  0], [ 0,  0,  1],  [0, -1,  0]],
    down:  Matrix[[1,  0,  0], [ 0,  0, -1],  [0,  1,  0]],
    left:  Matrix[[0,  1,  0], [-1,  0,  0],  [0,  0,  1]],
    right: Matrix[[0, -1,  0], [ 1,  0,  0],  [0,  0,  1]],
  }
  FACES = {
    top:     Vector[ 0,  1,  0],
    bottom:  Vector[ 0, -1,  0],
    left:    Vector[-1,  0,  0],
    right:   Vector[ 1,  0,  0],
    front:   Vector[ 0,  0, -1],
    back:    Vector[ 0,  0,  1],
  }
  class Cube < Grid
    attr_reader :faces, :twod_projection, :current_x, :current_y, :current_orientation, :current_sheet
    def initialize(twod_projection, size:)
      @size = size
      @twod_projection = twod_projection
      super twod_projection.turn_to_sheets(size: size)
      bottom_sheet = coords.find { |sheet| self[*sheet] }
      @faces = { bottom: { sheet: self[*bottom_sheet], path: [] } }

      @current_x = 0
      @current_y = 0
      @current_sheet = self[0].compact.first
      @current_orientation = 0

      traverse_sheets(bottom_sheet) do |root, connected, (*path, move)|
        cube_face = @faces.find { |_,face| face[:sheet] == root }.first
        root_face = FACES[cube_face]

        orient_move = path.map { |dir| ROTATIONS[dir] }.reduce(&:*) || Matrix::I(3)
        face = root_face + orient_move * MOVES[move]

        face_orientation = FACES.invert[face]
        @faces[face_orientation] = { sheet: connected, path: [*path, move] }
      end
      connect_sheets(@faces)
    end

    def traverse_sheets(from, queue=[], paths={ from => [] }, &block)
      return true unless from

      offsets = { [1,0] => :right, [0,1] => :down, [-1,0] => :left, [0,-1] => :up }
      offsets.each do |offset, direction|
        coord = (Vector[*from] + Vector[*offset]).to_a
        next if self[*coord].nil?
        next if paths.include? coord

        neighbor = self[*coord]
        path = paths[from] + [direction]
        yield self[*from], neighbor, path

        paths[coord] = path
        queue << coord
      end
      traverse_sheets(queue.shift, queue, paths, &block)
    end

    def connect_sheets(face_structure)
      # Relations aren't symmetric
      face_structure.to_a.permutation(2) do |(face_orientation, face), (target_orientation, target)|
        path = face[:path]
        final_move = MOVES.find do |direction, move|
          root_face = FACES[face_orientation]
          target_face = FACES[target_orientation]

          orient_move = path.map { |dir| ROTATIONS[dir] }.reduce(&:*) || Matrix::I(3)
          final_face = root_face + orient_move * move

          final_face == target_face
        end&.first
        puts "#{face_orientation}->#{target_orientation}: #{final_move}"
        next unless final_move # opposite faces
        face[:sheet].send(:"#{final_move}_sheet=", target[:sheet])
      end
    end

    STEPS = {
      up: [0, -1],
      down: [0, 1],
      left: [-1, 0],
      right: [1, 0],
    }
    def forward(n)
      n.times do
        direction = DIRECTIONS[@current_orientation]
        step_x, step_y = *STEPS[direction]
        @twod_projection[*@current_sheet[@current_x, @current_y]] = DISPLAY[direction]
        new_x, new_y, new_sheet, new_orientation = @current_x + step_x, @current_y + step_y, @current_sheet, @current_orientation
        if @current_sheet.out_of_bounds?(new_x, new_y)
          new_sheet = @current_sheet.neighbor_sheets[direction]
          arrival_source = new_sheet.neighbor_sheets.find { |_,s| s == @current_sheet }.first
          new_orientation = (DIRECTIONS.index(arrival_source)+2) % 4
          new_x = case arrival_source
          when :left then 0
          when :right then @size - 1
          when :up
            case direction
            when :down then @current_x
            when :up then @size - 1 - @current_x
            when :left then @current_y
            when :right then @size - 1 - @current_y
            end
          when :down
            case direction
            when :up then @current_x
            when :down then @size - 1 - @current_x
            when :right then @current_y
            when :left then @size - 1 - @current_y
            end
          end
          new_y = case arrival_source
          when :up then 0
          when :down then @size - 1
          when :left
            case direction
            when :right then @current_y
            when :left then @size - 1 - @current_y
            when :up then @current_x
            when :down then @size - 1 - @current_x
            end
          when :right
            case direction
            when :left then @current_y
            when :right then @size - 1 - @current_y
            when :down then @current_x
            when :up then @size - 1 - @current_x
            end
          end
        end
        break if @twod_projection[*new_sheet[new_x,new_y]] == Sheet::WALL
        @current_x, @current_y, @current_sheet, @current_orientation = new_x, new_y, new_sheet, new_orientation
      end
    end

    DISPLAY = { up: '^', down: 'v', right: '>', left: '<' }

    ROTATION = { 'R' => 1, 'L' => -1 }
    DIRECTIONS = %i[right down left up]
    def turn(instruction)
      return unless instruction
      @current_orientation = (@current_orientation + ROTATION[instruction]) % 4
    end
  end

  ROTATION = { 'R' => 1, 'L' => -1 }
  DIRECTIONS = %i[right down left up]

  DISPLAY = { up: '^', down: 'v', right: '>', left: '<' }

  def first_part
    map = input[:map]

    initial_coords = [map[0].index(Sheet::FREE), 0]
    state = { pos: initial_coords, facing: 0 }
    input[:directions].each_slice(2).each_with_object(state) do |(move, rot), current|
      move.times do
        direction = DIRECTIONS[state[:facing]]

        map[*current[:pos]] = DISPLAY[direction]
        new_pos = map.send(direction, *state[:pos])
        break unless new_pos

        state[:pos] = new_pos
      end
      state[:facing] = (state[:facing] + ROTATION[rot]) % 4 if rot
    end

    x, y = state[:pos]
    (y+1) * 1000 + (x+1) * 4 + state[:facing]
  end

  def second_part
    twod_projection = input[:map]
    cube = Cube.new(twod_projection, size: cube_size)
    input[:directions].each_slice(2) do |move, rot|
      cube.forward(move)
      cube.turn(rot) if rot
    end
    byebug
    x,y = cube.current_sheet[cube.current_x, cube.current_y]
    p cube.twod_projection
    (y+1) * 1000 + (x+1) * 4 + cube.current_orientation
  end

  private

  def cube_size
    debug? ? 4 : 50
  end

  def convert_data(data)
    map, directions = data.split("\n\n")

    map = map.split("\n").then do |lines|
      lines.map { |line| line.ljust(lines.map(&:length).max, ' ').chars }
    end.then { |chars| Sheet.new(chars) }

    directions = directions.strip.scan(/(\d+|\D+)/).flatten.map { |dir| dir.to_i.to_s == dir ? dir.to_i : dir }

    { map: map, directions: directions }
  end
end

Day22.solve
