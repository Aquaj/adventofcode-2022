require_relative 'common'

class Day8 < AdventDay
  EXPECTED_RESULTS = { 1 => 21, 2 => nil }

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
  end

  private

  def convert_data(data)
    Grid.new(super.map(&:chars))
  end
  alias_method :tree_map, :input
end

Day8.solve
