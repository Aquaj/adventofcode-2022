require_relative 'common'

class Day14 < AdventDay
  EXPECTED_RESULTS = { 1 => 24, 2 => 93 }

  SAND_SOURCE = [500, 0]

  def first_part
    occupied_spaces = rock_coords

    (1..).find do |sand_unit|
      resting_place = fall_from(SAND_SOURCE, obstacles: occupied_spaces)
      occupied_spaces.add resting_place
      resting_place == FREE_FALL
    end - 1
  end

  def second_part
    occupied_spaces = rock_coords.tap(&:finalize!)

    (1..).find do |sand_unit|
      resting_place = fall_from(SAND_SOURCE, obstacles: occupied_spaces)
      occupied_spaces.add resting_place
      resting_place == SAND_SOURCE
    end
  end

  private

  FREE_FALL = Object.new.tap { def _1.inspect = 'FREE FALL' }.freeze
  def fall_from(coords, obstacles:)
    first_obstacle = obstacles.under(coords)
    return FREE_FALL unless first_obstacle

    block_x, block_y = *first_obstacle
    next_blocks = [ [block_x - 1, block_y], [block_x + 1, block_y] ]
    free_space = next_blocks.find { |block| !obstacles.include?(block) }
    return [block_x, block_y - 1] unless free_space

    fall_from(free_space, obstacles: obstacles)
  end

  class Obstacles
    def initialize
      @blocks = Hash.new { |h, k| h[k] = Set.new([@floor_y].compact) }
      @floor_y = nil

      @cache = Hash.new { |h,k| h[k] = {} }
    end

    def finalize!
      lowest_block = @blocks.values.reduce(&:|).max
      @floor_y = lowest_block + 2
      @blocks.each { |x,ys| ys << @floor_y }
    end

    def add(coords)
      x,y = coords
      @blocks[x] << y
      @cache[x].transform_values! { |v| y < v ? y : v }
    end

    def include?(coords)
      @blocks[coords[0]].include? coords[1]
    end

    def under(coords)
      source_x, source_y = coords

      y_under = @cache[source_x].fetch(source_y) do
        first_under = @blocks[source_x].sort.find { |y| y > source_y } || @floor_y
        (source_y..first_under).each { |y| @cache[source_x][y] = first_under } if first_under
        first_under
      end
      [source_x, y_under] if y_under
    end
  end

  def rock_coords
    rock_paths.each_with_object(Obstacles.new) do |coords, spaces|
      coords.each_cons(2) do |(x1,y1),(x2,y2)|
        # Only one of the two is necessary each time but logic wise
        # it's simpler to run both and it doesn't do any harm
        x1.towards(x2).each { |x| spaces.add [x,y1] } # y1 == y2
        y1.towards(y2).each { |y| spaces.add [x1,y] } # x1 == x2
      end
    end
  end

  def convert_data(data)
    super.map do |rock_path|
      rock_path.split(' -> ').map { |coords| coords.split(',').map(&:to_i) }
    end
  end
  alias_method :rock_paths, :input
end

Day14.solve
