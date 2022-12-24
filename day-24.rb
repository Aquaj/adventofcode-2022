require_relative 'common'

class Day24 < AdventDay
  include Algorithms

  module BitOps
    refine Integer do
      def bitrot_right(n, size:)
        n = n % size
        ((self >> n) | (self << (size - n))) & (2**size-1)
      end

      def bitrot_left(n, size:)
        n = n % size
        ((self << n) | (self >> (size - n))) & (2**size-1)
      end
    end
  end
  using BitOps

  EXPECTED_RESULTS = { 1 => 18, 2 => 54 }

  class Valley
    BLIZZARD_CHARS = { up: '^', down: 'v', left: '<', right: '>' }
    attr_reader :height, :width

    def initialize(height, width)
      @height, @width = height, width
      @masks = {
        up: Array.new(width, 0),
        down: Array.new(width, 0),
        left: Array.new(height, 0),
        right: Array.new(height, 0),
      }
    end

    def register_blizzard(x,y, direction)
      masks = @masks[direction]
      case direction
      when :up, :down
        masks[x] |= 2**(height - 1 - y)
      when :left, :right
        masks[y] |= 2**(width - 1 - x)
      end
      # invalidating cache – should never happen in our exercise but the idea of
      # keeping obsolete cache stresses me out
      @gridmask, @next_valley = nil
      true
    end

    def gridmask
      return @gridmask if @gridmask

      gridmasks = masks.map do |dir, mask_coll|
        vert = [:up, :down].include? dir

        bits = mask_coll.map do |mask|
          mask.to_s(2).rjust((vert ? height : width), '0').chars.map(&:to_i)
        end

        bits = bits.transpose if vert

        bits
      end

      first, *rest = gridmasks

      gridmasks = first.zip(*rest).map do |first_m, *rest_m|
        first_m.zip(*rest_m).map { |c| c.sum != 0 }
      end

      @gridmask = Grid.new gridmasks
    end

    def neighbors_of(x,y)
      @neighbors ||= {}
      @neighbors[[x,y]] ||= begin
        potential_neighbours = [[x,y+1],[x,y-1],[x+1,y],[x-1,y]]

        potential_neighbours.reject! { |(x,y)| blizzard?(x,y) }
        potential_neighbours.reject! { |(x,y)| x < 0 || x >= width || y < 0 || y >= height }

        potential_neighbours << [0, -1] if [x,y] == [0,0] # Entry
        exit_step = [width - 1, height - 1]
        potential_neighbours << [width - 1, height] if [x,y] == exit_step # Exit
        potential_neighbours
      end
    end

    def blizzard?(x,y)
      gridmask[x,y]
    end

    protected attr_accessor :masks
    def next_minute
      return @next_valley if @next_valley

      next_masks = self.masks.map do |dir, coll|
        [dir, coll.map do |mask|
          case dir
          when :up    then mask.bitrot_left(1, size: height)
          when :left  then mask.bitrot_left(1, size: width)
          when :right then mask.bitrot_right(1, size: width)
          when :down  then mask.bitrot_right(1, size: height)
          end
        end]
      end.to_h

      next_v = Valley.new(height, width)
      next_v.masks = next_masks
      @next_valley = next_v
    end

    def render
      grid = Array.new(height) { Array.new(width) { [] } }
      @masks.each do |dir, mask_coll|
        char = BLIZZARD_CHARS[dir]
        vert = [:up, :down].include? dir

        bits = mask_coll.map do |mask|
          mask.to_s(2).rjust((vert ? height : width), '0').chars
        end

        bits = bits.transpose if vert

        bits.each_with_index do |row, y|
          row.each_with_index { |c, x| grid[y][x] << char if c == '1' }
        end
      end
      grid.each do |row|
        puts(row.map do |blizzards|
          next '.' if blizzards.empty?
          next blizzards.count if blizzards.count > 1
          blizzards.unwrap
        end.join)
      end
      puts
    end
  end

  def first_part
    valley = input
    start = [0, -1]
    goal = [valley.width - 1, valley.height]

    find_route(start, goal, valley).length - 1
  end

  def second_part
    valley = input
    start = [0, -1]
    goal = [valley.width - 1, valley.height]

    way_there = find_route(start, goal, valley)

    way_back = find_route(goal, start, way_there.last.valley)

    way_there_again =find_route(start, goal,  way_back.last.valley)

    way_there.length - 1 +
      way_back.length - 1 +
      way_there_again.length - 1
  end

  private

  TimeCoord = Struct.new(:x,:y,:valley) do
    def moves
      next_valley = valley.next_minute
      coords = next_valley.neighbors_of(x, y)
      coords << [x,y] unless next_valley.blizzard?(x,y)
      coords.map { |c| self.class.new(*c, next_valley) }
    end
  end

  def find_route(start, goal, valley)
    start = TimeCoord.new(*start, valley)

    seen = Set.new
    previous = {}
    shortest_time = { start => 0 }.with_default(Float::INFINITY)

    candidate_set = Set.new
    candidates = PriorityQueue.new()
    heuristic = ->(pos) { [-shortest_time[pos], -(goal[0] - pos.x) + (goal[1] - pos.y)] } # Manhattan distance

    candidate_set << start
    candidates.push(start, 0)
    count = 0
    while curr_pos = candidates.pop
      candidate_set.delete curr_pos
      return paths_from(previous: previous, goal: curr_pos).reverse if [curr_pos.x, curr_pos.y] == goal

      current_time = shortest_time[curr_pos] + 1

      seen << curr_pos
      curr_pos.moves.each do |move|
        next if seen.include? move

        if current_time < shortest_time[move]
          previous[move] = curr_pos
          shortest_time[move] = current_time
        end
        unless candidate_set.include?(move)
          candidate_set << move
          candidates.push(move, heuristic.call(move))
        end
      end
    end

    nil
  end

  def convert_data(data)
    lines = super
    # Ignoring walls
    valley = Valley.new(lines.size - 2, lines.first.size - 2)
    lines[1...-1].each_with_index do |line, y|
      line.chars[1...-1].each_with_index do |char, x|
        next unless direction = Valley::BLIZZARD_CHARS.invert[char]
        valley.register_blizzard(x,y, direction)
      end
    end
    valley
  end
end

Day24.solve
