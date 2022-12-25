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
    up_bound     = 0
    left_bound   = 0
    right_bound  = tree_map.width  - 1
    bottom_bound = tree_map.height - 1

    tree_map.coords.map do |(x,y)|
      current_tree = tree_map[x,y]

      dirs = {
        up:    (y-1).towards(up_bound),
        left:  (x-1).towards(left_bound),
        right: (x+1).towards(right_bound),
        down:  (y+1).towards(bottom_bound),
      }

      up    = dirs[:up].find.with_index    { |n,i| break i if tree_map[x,n] >= current_tree } unless y == up_bound
      left  = dirs[:left].find.with_index  { |n,i| break i if tree_map[n,y] >= current_tree } unless x == left_bound
      right = dirs[:right].find.with_index { |n,i| break i if tree_map[n,y] >= current_tree } unless x == right_bound
      down  = dirs[:down].find.with_index  { |n,i| break i if tree_map[x,n] >= current_tree } unless y == bottom_bound

      up    = up    ? up    + 1 : (up_bound - y).abs
      left  = left  ? left  + 1 : (left_bound - x).abs
      right = right ? right + 1 : (right_bound - x).abs
      down  = down  ? down  + 1 : (bottom_bound - y).abs

      up * left * right * down
    end.max
  end

  private

  def convert_data(data)
    Grid.new(super.map(&:chars).map { |r| r.map(&:to_i) })
  end
  alias_method :tree_map, :input
end

Day8.solve if __FILE__ == $0
