require_relative 'common'

class Day18 < AdventDay
  EXPECTED_RESULTS = { 1 => 64, 2 => 58 }

  def first_part
    cubes = compute_neighbors(lava_coords)

    cubes.sum { |cube, neighbors| 6 - neighbors.count }
  end

  LavaCube = Struct.new(:coords, :neighbors)
  def second_part
    air = Set.new
    cubes.each do |coords, cube|
      lava, air_cubes = neighbors_3d(coords).partition { |pos| cubes[pos] }
      cube.neighbors = lava.map { |c| cubes[c] }
      air += air_cubes
    end
    pockets = air.reduce(components) do |bubble|
      pocket = full_pocket bubble, cubes.values
    end
    air = pockets.reduce(&:+)
    air_neighbors = {}
    air.each do |coords|
      neighbors = neighbors_3d(coords)
      air_neighbors[coords] = neighbors.select { |n| air.include? n }
    end

    cubes.count * 6 - cubes.values.map(&:neighbors).map(&:count).sum - pockets.uniq.map { |p| p.count * 6 - p.sum { |c| air_neighbors[c].count } }.sum
  end

  private

  def neighbors_3d(coords)
    x,y,z = *coords
    [
      [x-1,y,z], [x+1,y,z],
      [x,y-1,z], [x,y+1,z],
      [x,y,z-1], [x,y,z+1],
    ]
  end

  def compute_neighbors(cubes)
    cubes.each_with_object({}) do |coords, neighbors|
      neighbors_pos = neighbors_3d(coords)
      neighbors[coords] = neighbors_pos.select { |n| cubes.include? n }
    end
  end

  # BFS-ing our way into either the wall (pocket)
  # or the outside world (not pocket)
  def full_pockets(coord, glob)
    min_x, max_x = glob.map { |c| c[0] }.minmax
    min_y, max_y = glob.map { |c| c[1] }.minmax
    min_z, max_z = glob.map { |c| c[2] }.minmax

    current = coord
    queue = []
    discovered = Set.new([current])
    until current.nil? do
      neighbors_3d(current).each do |node|
        next if discovered.include?(node) || glob.include?(node)

        return false if node[0] < min_x || node[0] > max_x
        return false if node[1] < min_y || node[1] > max_y
        return false if node[2] < min_z || node[2] > max_z
        discovered << node
        queue << node
      end

      current = queue.shift
    end
    return discovered
  end

  def convert_data(data)
    super.map { |cube| cube.split(',').map(&:to_i) }
  end
  alias_method :lava_coords, :input
end

Day18.solve
