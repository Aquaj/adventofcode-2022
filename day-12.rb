require_relative 'common'
require_relative 'support/algorithms'

class Day12 < AdventDay
  include Algorithms

  EXPECTED_RESULTS = { 1 => 31, 2 => 29 }

  class Mountain < Grid
    include Grid::GraphMethods

    START_NODE = 'S'
    END_NODE = 'E'

    attr_reader :start, :finish, :trail_starts

    def initialize(grid)
      super

      @start = nil
      @finish = nil
      @trail_starts = []

      Grid.new(grid).bfs_traverse([0,0]) do |value, coords|
        break if @start && @end
        @start = coords if value == START_NODE
        @finish = coords if value == END_NODE
        @trail_starts << coords if trail_start?(coords)
      end
    end

    ALTITUDES = ('a'..'z').
      map.with_index { |c,i| [c, i] }.to_h.
      merge(START_NODE => 0, END_NODE => 25)

    def altitude_of(node)
      ALTITUDES[self[*node]]
    end

    def trail_start?(node)
      ALTITUDES[self[*node]] == ALTITUDES[START_NODE]
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

    def edge_cost(*)
      1
    end
  end

  class ReverseMountain < Mountain
    def altitude_of(node)
      ALTITUDES[END_NODE] - super(node)
    end
  end

  def first_part
    mountain = Mountain.new(readout)

    distances = dijkstra(mountain.start, mountain, mountain.finish)[:distances]
    distances[mountain.finish]
  end

  def second_part
    mountain = ReverseMountain.new(readout)

    distances = dijkstra(mountain.finish, mountain)[:distances]
    mountain.trail_starts.map { |beginning| distances[beginning] }.min
  end

  private

  def convert_data(data)
    super.map do |line|
      line.chars
    end
  end
  alias_method :readout, :input
end

Day12.solve
