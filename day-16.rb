require_relative 'common'
require 'algorithms'

class Day16 < AdventDay
  EXPECTED_RESULTS = { 1 => 1651, 2 => nil }

  MINUTES_BEFORE_ERUPTION = 30
  START_VALVE_NAME = "AA"

  def first_part
    @count = @cache = 0
    optimized_valveset = optimize(valves)
    path = optimal_moves(optimized_valveset.find { |v| v.name == START_VALVE_NAME })
    puts path.map(&:inspect)
    total_pressure(path)[:pressure]
  end

  Graph = Struct.new(:nodes, :edges) do
    def edge_cost(v,n)
      v.neighbors[n]
    end
  end

  def optimize(start)
    edges = valves.flat_map { |v| v.neighbors.map { |n,d| [v, n] } }
    graph = Graph.new(valves, edges)
    new_valves = valves.map(&:dup)
    new_valves.each do |valve|
      old = valves.find { |v| v.name == valve.name }
      new_distances = Algorithms.bellman_ford(old, graph)[:distances]
      valve.neighbors = new_distances.without(valve).map do |old, distance|
        new = new_valves.find { |v| v.name == old.name }
        [new, distance]
      end.reject { |v,_| v.jammed? }.sort_by { |v,_| v.flow_rate }.to_h
    end
    new_valves.to_set
  end

  def second_part
  end

  private

  def optimal_moves(current_valve, time: MINUTES_BEFORE_ERUPTION, open_valves: Set.new, cache: {})
    return [] if time == 0
    return ([WAIT]*time) if open_valves.count == valves.reject { |v| v.jammed? }.count

    cache_key = [current_valve.hash, time, open_valves.map(&:hash).sort]

    p @count if (@count += 1) % 1000 == 0
    cache[cache_key] ||= begin
      @cache += 1
      paths = current_valve.actions.filter_map do |action|
        next if open_valves.include? action.opens_valve
        next if time - action.time_cost < 0

        [action] + optimal_moves(
          action.move_to,
          time: time - action.time_cost,
          open_valves: open_valves + [action.opens_valve].compact,
          cache: cache,
        )
      end
      max = paths.max_by {|e| total_pressure(e)[:pressure] }
      max || ([WAIT]*time) # If we can't do anything...
    end
  end

  def total_pressure(moves)
    moves.each_with_object({rate: 0, pressure: 0}) do |action, result|
      result[:pressure] += result[:rate] * action.time_cost
      result[:rate] += action.opens_valve&.flow_rate || 0
    end
  end

  Action = Struct.new(:time_cost, :move_to, :opens_valve, keyword_init: true)
  class Travel < Action; def inspect = "Travel<#{move_to.name} : #{time_cost}mn>"; end
  class ValveOpening < Action; def inspect = "Open<#{opens_valve.name} +#{opens_valve.flow_rate}>"; end
  WAIT = Action.new(time_cost: 1, move_to: self, opens_valve: nil).tap { |w| def w.inspect = 'WAIT' }

  Valve = Struct.new(:name, :flow_rate, :neighbors, keyword_init: true) do
    def inspect = "#{self.class.name}<#{name}: #{flow_rate} — #{neighbors.transform_keys(&:name).inspect}>"
    def to_s = inspect
    def hash = object_id
    def jammed? = flow_rate == 0
    def actions
      [
        (ValveOpening.new(time_cost: 1, move_to: self, opens_valve: self) unless jammed?),
        *neighbors.map do |neighbor, distance|
          Travel.new(time_cost: distance, move_to: neighbor, opens_valve: nil)
        end.sort_by(&:time_cost)
      ].compact
    end
  end

  FORMAT = /Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? (.*)/
  def convert_data(data)
    super.map do |valve|
      info = valve.match(FORMAT)&.captures
      raise "Bad valve format" unless info
      Valve.new(name: info[0], flow_rate: info[1].to_i, neighbors: info[2].split(', '))
    end.then do |valves|
      # Convert neighbors from names to the actual Valve objects
      valves.each do |valve|
        neighbor_objects = valves.select { |neighbor| valve.neighbors.include? neighbor.name }
        valve.neighbors = neighbor_objects.map { |n| [n, 1] }.to_h
      end
    end
  end
  alias_method :valves, :input
end

Day16.solve
