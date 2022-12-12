require_relative 'common'
require_relative 'support/algorithms'

class Day12 < AdventDay
  include Algorithms

  EXPECTED_RESULTS = { 1 => 31, 2 => nil }

  class Mountain < Grid
    include Grid::GraphMethods

    START_NODE = 'S'
    END_NODE = 'E'

    attr_reader :start, :finish

    def initialize(grid)
      super

      @start = nil
      @finish = nil

      Grid.new(grid).bfs_traverse([0,0]) do |value, coords|
        break if @start && @end
        @start = coords if value == START_NODE
        @finish = coords if value == END_NODE
      end
    end

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
    distance = dijkstra(mountain.start, mountain, mountain.finish)[:distances]
    distance[end_goal]
  end

  def second_part
  end

  private

  def mountain
    @mountain ||= Mountain.new(readout)
  end

  def convert_data(data)
    super.map do |line|
      line.chars
    end
  end
  alias_method :readout, :input
end

Day12.solve
