require_relative 'common'

class Day8 < AdventDay
  EXPECTED_RESULTS = { 1 => 21, 2 => 8 }

  def first_part
    tree_map.coords.count do |(x,y)|
      current_tree = tree_map[x,y]

      (0...x).all? { |n| tree_map[n,y] < current_tree } ||
        (x+1...tree_map.width).all? { |n| tree_map[n,y] < current_tree } ||
        (0...y).all? { |n| tree_map[x,n] < current_tree } ||
        (y+1...tree_map.height).all? { |n| tree_map[x,n] < current_tree }
    end
  end

  def second_part
    tree_map.coords.map do |(x,y)|
      current_tree = tree_map[x,y]

      boundary_up = (y-1).towards(0).find.with_index { |n,i| break i if tree_map[x,n] >= current_tree } unless y == 0
      boundary_left = (x-1).towards(0).find.with_index { |n,i| break i if tree_map[n,y] >= current_tree } unless x == 0
      boundary_right = (x+1).towards(tree_map.width - 1).find.with_index { |n,i| break i if tree_map[n,y] >= current_tree } unless x == tree_map.width - 1
      boundary_down = (y+1).towards(tree_map.height - 1).find.with_index { |n,i| break i if tree_map[x,n] >= current_tree } unless y == tree_map.height - 1

      boundary_up = boundary_up ? boundary_up + 1 : y
      boundary_left = boundary_left ? boundary_left + 1 : x
      boundary_right = boundary_right ? boundary_right + 1 : tree_map.width - 1 - x
      boundary_down = boundary_down ? boundary_down + 1 : tree_map.height - 1 - y

      boundary_up * boundary_left * boundary_right * boundary_down
    end.max
  end

  private

  def convert_data(data)
    Grid.new(super.map(&:chars).map { |r| r.map(&:to_i) })
  end
  alias_method :tree_map, :input
end

Day8.solve
