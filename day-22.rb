require_relative 'common'

class Day22 < AdventDay
  EXPECTED_RESULTS = { 1 => 6032, 2 => 5031 }

  class Agent < Struct.new(:coordinates,:orientation,:support, keyword_init: true)
    ROTATION = { 'R' => 1, 'L' => -1 }
    DIRECTIONS = %i[right down left up]

    Direction = Struct.new(:name, :vector, :opposite)
    STEPS = {
      up: Direction.new(:up, [0, -1], :down),
      down: Direction.new(:down, [0, 1], :up),
      left: Direction.new(:left, [-1, 0], :right),
      right: Direction.new(:right, [1, 0], :left),
    }.tap { |steps| steps.each { |_,d| d[:opposite] = steps[d[:opposite]] } }

    DISPLAY = { up: '^', down: 'v', right: '>', left: '<' }

    def forward(n)
      n.times do
        # Used for rendering
        support.mark(coordinates, DISPLAY[orientation])

        move, new_orientation = support.find_next_in(STEPS[orientation], from: coordinates)
        self.orientation = STEPS.invert[new_orientation] if new_orientation
        # support.display
        return unless move

        self.coordinates = move
      end
    end

    def turn(way)
      self.orientation = DIRECTIONS[(orientation_index + ROTATION[way]) % 4]
    end

    def orientation_index
      DIRECTIONS.index(orientation)
    end
  end

  class Map < Grid
    Coordinates = Struct.new(:x,:y)

    OUT = ' '
    WALL = '#'
    FREE = '.'

    def starting_coords
      # Topmost leftmost free spot
      Coordinates.new(self[0].index(FREE), 0)
    end

    def find_next_in(direction, from:)
      new_x,new_y = *from
      loop do
        new_x = (new_x + direction.vector[0]) % self.width
        new_y = (new_y + direction.vector[1]) % self.height
        break unless out_of_bounds?(new_x, new_y)
      end
      return nil if self[new_x,new_y] == WALL
      Coordinates.new(new_x,new_y)
    end

    def mark(coords, symbol)
      self[*coords] = symbol
    end

    def display
      puts inspect
      puts
    end

    def out_of_bounds?(x,y)
      super || self[y][x] == OUT
    end

    # Cut into squares of `size` and remove the ones that are empty
    # Sheets contain no values from the map but only coordinates of what point
    # they track back to on the original
    def turn_to_sheets(size:)
      localized = self.to_a.map.with_index { |r,y| r.map.with_index { |c,x| [x,y] } }
      localized.each_slice(size).map.with_index do |(first, *rows)|
        first.zip(*rows).each_slice(size).map.with_index do |(head, *cols)|
          sheet = head.zip(*cols)
          sheet.flatten(1).none? { |v| self[*v] } ? nil : Sheet.new(sheet)
        end
      end
    end
  end

  class Sheet < Map
    attr_reader :neighbor_sheets

    def initialize(*)
      super
      @neighbor_sheets = {
        up: nil,
        down: nil,
        left: nil,
        right: nil,
      }
    end
  end

  class Cube < Grid
    MOVES = { # moving <dir> on the sheet brings me to <face> on the cube
      up:    Vector[ 0,  1,  1],
      down:  Vector[ 0,  1, -1],
      left:  Vector[-1,  1,  0],
      right: Vector[ 1,  1,  0],
    }
    ROTATIONS = { # changing reference point
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
    Coordinates = Struct.new(:x, :y, :sheet)

    attr_reader :faces, :map, :size

    def initialize(map, size:)
      @map = map
      @size = size
      super map.turn_to_sheets(size: size)
      construct_cube
    end

    module Construction
      # Fold the paper into a cube, then glue the edges
      def construct_cube
        @faces = fold_sheets
        connect_sheets(@faces)
      end

      # Go square by square and store the correspoonding sheet as the face it's
      # supposed to match + the path we took on the flat map to get there so we
      # can glue them later
      def fold_sheets
        bottom_sheet = coords.find { |sheet| self[*sheet] }
        faces = { bottom: { sheet: self[*bottom_sheet], path: [] } }

        traverse_sheets(bottom_sheet) do |root_sheet, connected_sheet, (*path, move)|
          root_face = faces.find { |_,s| s[:sheet] == root_sheet }.first
          root_coords = FACES[root_face]

          new_face = face_after_move(root_coords, move, path)
          face_orientation = FACES.invert[new_face]

          faces[face_orientation] = { sheet: connected_sheet, path: [*path, move] }
        end
        faces
      end

      # Moving through the cube as we move through the flat outline
      # each move has to be rotated according to the current folds (path)
      # for all faces we walked through before being applied
      def face_after_move(from_face, move, path_to_here)
        orienting = path_to_here.map { |dir| ROTATIONS[dir] }.reduce(&:*) || Matrix::I(3)
        from_face + orienting * MOVES[move]
      end

      # BFSing through the unfolded cube and storing paths along the way
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

      # For each pair, find the next ones by trying moves and seeing which ones
      # fit then fix them by keeping references
      def connect_sheets(face_structure)
        # Relations aren't symmetric so we need both 1->2 and 2->1
        face_structure.to_a.permutation(2) do |(face_orientation, face), (target_orientation, target)|
          path = face[:path]
          final_move = MOVES.keys.find do |direction|
            root_face = FACES[face_orientation]
            target_face = FACES[target_orientation]

            face_after_move(root_face, direction, path) == target_face
          end

          next unless final_move # opposite faces

          face[:sheet].neighbor_sheets[final_move] = target[:sheet]
        end
      end
    end
    include Construction

    def mark(coords, symbol)
      map_coords = coords.sheet[coords.x, coords.y]
      @map[*map_coords] = symbol
    end

    def display
      @map.display
    end

    def starting_coords
      # Leftmost topmost free spot on the topmost leftmost sheet
      starting_sheet = self[0].compact.first
      Coordinates.new(starting_sheet[0].index { |c| map[*c] == Map::FREE }, 0, starting_sheet)
    end

    def find_next_in(direction, from:)
      new_x = from.x + direction.vector[0]
      new_y = from.y + direction.vector[1]

      map_coord = from.sheet[new_x, new_y]

      unless from.sheet.out_of_bounds?(new_x, new_y)
        return if @map[*map_coord] == Sheet::WALL
        return Coordinates.new(new_x, new_y, from.sheet), nil
      end

      new_sheet = from.sheet.neighbor_sheets[direction.name]

      entering_from = new_sheet.neighbor_sheets.invert[from.sheet]
      new_orientation = Agent::STEPS[entering_from].opposite

      pos = %i[up right down left].cycle
      rot = Matrix[[0 , -1], [1, 0]]

      # Computing the rotation from the current referential to the new one
      a = direction.vector
      b = new_orientation.vector

      rot = Matrix[
        [a[0]*b[0] + a[1]*b[1], b[0]*a[1] - a[0]*b[1]],
        [a[0]*b[1] - b[0]*a[1], a[0]*b[0] + a[1]*b[1]],
      ]

      center = Vector[(@size-1)/2.0, (@size-1)/2.0]
      new_pos = (rot * (Vector[from.x, from.y] - center)) + center
      new_pos -= Vector[@size-1, 0] if [:left, :right].include? entering_from
      new_pos -= Vector[0, @size-1] if [:up, :down].include? entering_from

      new_x, new_y = new_pos.to_a.map(&:to_i).map(&:abs)
      map_coord = new_sheet[new_x, new_y]
      return if @map[*map_coord] == Sheet::WALL

      return Coordinates.new(new_x, new_y, new_sheet), new_orientation
    end
  end

  def first_part
    map = input[:map]
    agent = Agent.new(coordinates: map.starting_coords, orientation: :right, support: map)

    input[:directions].each_slice(2).each_with_object(agent) do |(move, rot), agent|
      agent.forward(move)
      agent.turn(rot) if rot
    end

    (agent.coordinates.y+1) * 1000 + (agent.coordinates.x+1) * 4 + agent.orientation_index
  end

  def second_part
    map = input[:map]
    cube = Cube.new(map, size: cube_size)

    agent = Agent.new(coordinates: cube.starting_coords, orientation: :right, support: cube)

    input[:directions].each_slice(2).each_with_object(agent) do |(move, rot), agent|
      agent.forward(move)
      agent.turn(rot) if rot
    end

    coords = agent.coordinates
    x,y = coords.sheet[coords.x, coords.y]
    (y+1) * 1000 + (x+1) * 4 + agent.orientation_index
  end

  private

  def cube_size
    debug? ? 4 : 50
  end

  def convert_data(data)
    map, directions = data.split("\n\n")

    map = map.split("\n").then do |lines|
      lines.map { |line| line.ljust(lines.map(&:length).max, ' ').chars }
    end.then { |chars| Map.new(chars) }

    directions = directions.strip.scan(/(\d+|\D+)/).flatten.map { |dir| dir.to_i.to_s == dir ? dir.to_i : dir }

    { map: map, directions: directions }
  end
end

Day22.solve
