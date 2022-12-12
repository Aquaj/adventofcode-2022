require_relative 'common'
require_relative 'support/algorithms'

class Day12 < AdventDay
  include Algorithms

  EXPECTED_RESULTS = { 1 => 31, 2 => nil }

  class Mountain < Grid
    include Grid::GraphMethods

    START_NODE = 'S'
    END_NODE = 'E'

    def diagonals? = false

    def altitude_of(node)
      return 0 if self[*node] == START_NODE
      return 25 if self[*node] == END_NODE
      ('a'..'z').to_a.index(self[*node])
    end

    def edges
      @edges ||= coords.flat_map do |s|
        coord_neighbors(*s).filter_map do |t|
          next unless altitude_of(t) <= altitude_of(s) + 1
          [s, t]
        end
      end
    end
    alias_method :coord_neighbors, :neighbors_of

    def neighbors(node)
      edges.select { |(s,_t)| s == node }.map(&:last)
    end

    def edge_cost(...)
      1
    end
  end

  def first_part
    mountain, start, finish = readout
    distance = dijkstra(start, mountain, finish)[:distances]
    distance[finish]
  end

  def second_part
  end

  private

  def convert_data(data)
    grid = super.map do |line|
      line.chars
    end
    start_coords = grid.find.with_index { |row, y| x = row.index(Mountain::START_NODE); break [x,y] if x }
    end_coords = grid.find.with_index { |row, y| x = row.index(Mountain::END_NODE); break [x,y] if x }
    [Mountain.new(grid), start_coords, end_coords]
  end
  alias_method :readout, :input
end

Day12.solve
