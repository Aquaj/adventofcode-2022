require_relative 'common'
require_relative 'support/algorithms'

class Day12 < AdventDay
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

      @terrain = Grid.new(grid)

      @terrain.dfs_traverse do |value, coords|
        @start = coords if value == START_NODE
        @finish = coords if value == END_NODE

        @trail_starts << coords if ALTITUDES[value] == ALTITUDES[START_NODE]
      end
    end

    ALTITUDES = ('a'..'z').zip(0..).to_h.
      merge(START_NODE => 0, END_NODE => 25)

    def altitude_of(node)
      ALTITUDES[self[*node]]
    end

    def coord_neighbors(node)
      @terrain.neighbors_of(*node)
    end

    def edge_cost(*)= 1

    def edges
      @edges ||= coords.flat_map do |s|
        coord_neighbors(s).filter_map do |t|
          next unless altitude_of(t) <= altitude_of(s) + 1
          [s, t]
        end
      end
    end

    def neighbors(node)
      @neighbors ||= edges.group_by(&:first).transform_values { |s_edges| s_edges.map(&:last) }
      @neighbors[node]
    end
  end

  class ReverseMountain < Mountain
    def altitude_of(node)
      ALTITUDES[END_NODE] - super(node)
    end
  end

  def first_part
    mountain = Mountain.new(readout)

    distances = Algorithms.dijkstra(mountain.start, mountain, mountain.finish)[:distances]
    distances[mountain.finish]
  end

  def second_part
    # Easier to go down than up !
    mountain = ReverseMountain.new(readout)

    distances = Algorithms.dijkstra(mountain.finish, mountain)[:distances]
    mountain.trail_starts.map { |trail_start| distances[trail_start] }.min
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
