require_relative 'common'

class Day18 < AdventDay
  EXPECTED_RESULTS = { 1 => 64, 2 => 58 }

  def first_part
    cubes = compute_neighbors(lava_coords)

    surface_area(cubes)
  end

  def second_part
    lava, air = compute_neighbors(lava_coords, track_adjacent: true)

    # compute pockets
    trapped_air = Set.new
    pockets = air.filter_map do |bubble|
      next if trapped_air.include? bubble
      pocket = full_pocket bubble, lava.keys.to_set
      next unless pocket
      trapped_air += pocket
      compute_neighbors(pocket)
    end

    surface_area(lava) - pockets.sum { |pocket| surface_area(pocket) }
  end

  private

  def surface_area(glob)
    glob.sum { |(cube, neighbors)| 6 - neighbors.count }
  end

  def neighbors_3d(coords)
    x,y,z = *coords
    [
      [x-1,y,z], [x+1,y,z],
      [x,y-1,z], [x,y+1,z],
      [x,y,z-1], [x,y,z+1],
    ]
  end

  def compute_neighbors(cubes, track_adjacent: false)
    cubes.each_with_object([{}.with_default(Set.new), Set.new]) do |coords, (neighbors_of, adjacent)|
      neighbors_pos = neighbors_3d(coords)
      neighbors, not_neighbors = neighbors_pos.partition { |n| cubes.include? n }

      neighbors_of[coords] = neighbors.to_set
      not_neighbors.each { |nn| adjacent << nn } if track_adjacent
    end.then { |(n,a)| track_adjacent ? [n,a] : n }
  end

  # BFS-ing our way into either the wall (pocket)
  # or the outside world (not pocket)
  def full_pocket(coord, lava)
    # Compute total bounds
    min_x, max_x = lava.map { |c| c[0] }.minmax
    min_y, max_y = lava.map { |c| c[1] }.minmax
    min_z, max_z = lava.map { |c| c[2] }.minmax

    current = coord
    queue = []
    discovered = Set.new([current])
    until current.nil? do
      neighbors_3d(current).each do |node|
        next if discovered.include?(node) || lava.include?(node)

        # Our bounds would be the lava if we were completely contained
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
    super.map { |cube| cube.split(',').map(&:to_i) }.to_set
  end
  alias_method :lava_coords, :input
end

Day18.solve if __FILE__ == $0
