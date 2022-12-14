require_relative 'common'

class Day14 < AdventDay
  EXPECTED_RESULTS = { 1 => 24, 2 => nil }

  SAND_SOURCE = [500, 0]

  def first_part
    occupied_spaces = Set.new + rock_coords

    (1..).find do |sand_unit|
      byebug
      resting_place = fall_from(SAND_SOURCE, obstacles: occupied_spaces)
      occupied_spaces << resting_place
      resting_place == FREE_FALL
    end - 1
  end

  def second_part
  end

  private

  FREE_FALL = Object.new.freeze
  def fall_from(coords, obstacles:)
    first_obstacle = obstacles.select { |(x,y)| x == coords[0] && y > coords[1] }.min_by { |(_,y)| y }
    return FREE_FALL unless first_obstacle

    block_x, block_y = *first_obstacle
    next_blocks = [ [block_x - 1, block_y], [block_x + 1, block_y] ]
    free_space = next_blocks.find { |block| !obstacles[block] }
    return [block_x, block_y - 1] unless free_space

    fall_from(free_space, obstacles: obstacles)
  end

  class ::Set
    def [](val)
      return val if self.include? val
    end
  end

  def rock_coords
    @rocks ||= rock_paths.each_with_object(Set.new) do |coords, spaces|
      coords.each_cons(2) do |(x1,y1),(x2,y2)|
        # Only one of the two is necessary each time but logic wise
        # it's simpler to run both and it doesn't do any harm
        x1.towards(x2).each { |x| spaces << [x,y1] } # y1 == y2
        y1.towards(y2).each { |y| spaces << [x1,y] } # x1 == x2
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
