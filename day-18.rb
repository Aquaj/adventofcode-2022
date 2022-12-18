require_relative 'common'

class Day18 < AdventDay
  EXPECTED_RESULTS = { 1 => 64, 2 => 58 }

  LavaCube = Struct.new(:coords, :neighbors) do
    def inspect = "L#{coords.inspect}"
  end

  def first_part
    cubes = lava_coords.map { |c| [c, LavaCube.new(c, Set.new)] }.to_h
    cubes.each do |coord, cube|
      cube.neighbors = cubes.slice(*neighbors_2d(coord)).values
    end
    cubes.count * 6 - cubes.values.map(&:neighbors).map(&:count).sum
  end

  def second_part
  end

  private

  def neighbors_2d(coords)
    x,y,z = *coords
    [
      [x-1,y,z], [x+1,y,z],
      [x,y-1,z], [x,y+1,z],
      [x,y,z-1], [x,y,z+1],
    ]
  end

  def convert_data(data)
    super.map { |cube| cube.split(',').map(&:to_i) }
  end
  alias_method :lava_coords, :input
end

Day18.solve
