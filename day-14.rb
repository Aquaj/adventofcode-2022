require_relative 'common'

class Day14 < AdventDay
  EXPECTED_RESULTS = { 1 => 24, 2 => 93 }

  SAND_SOURCE = [500, 0]

  def first_part
    occupied_spaces = rock_coords.deep_copy

    (1..).find do |sand_unit|
      resting_place = fall_from(SAND_SOURCE, obstacles: occupied_spaces)
      occupied_spaces << resting_place
      resting_place == FREE_FALL
    end - 1
  end

  def second_part
    occupied_spaces = rock_coords.deep_copy

    (1..).find do |sand_unit|
      resting_place = fall_from(SAND_SOURCE, obstacles: occupied_spaces)
      occupied_spaces << resting_place
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
      @blocks = {}
      @floor_y = nil
    end

    def finalize!
      lowest_block = @blocks.values.reduce(&:|).max
      @floor_y = lowest_block + 2
    end

    def <<(coords)
      x,y = coords
      @blocks[x] ||= Set.new
      @blocks[x] << y
    end

    def include?(coords)
      x,y = *coords
      return true if @blocks[x]&.include? y
      return true if @floor_y && (y >= @floor_y)
    end

    def under(coords)
      source_x, source_y = coords
      y_under = @blocks[source_x]&.select { |y| y > source_y }&.min
      first_under = [source_x, y_under] if y_under
      first_under || ([coords[0], @floor_y] if @floor_y)
    end
  end

  def rock_coords
    @rocks ||= rock_paths.each_with_object(Obstacles.new) do |coords, spaces|
      coords.each_cons(2) do |(x1,y1),(x2,y2)|
        # Only one of the two is necessary each time but logic wise
        # it's simpler to run both and it doesn't do any harm
        x1.towards(x2).each { |x| spaces << [x,y1] } # y1 == y2
        y1.towards(y2).each { |y| spaces << [x1,y] } # x1 == x2
      end
    end.tap { |o| o.finalize! if @part == 2 }
  end

  def convert_data(data)
    super.map do |rock_path|
      rock_path.split(' -> ').map { |coords| coords.split(',').map(&:to_i) }
    end
  end
  alias_method :rock_paths, :input
end

Day14.solve
