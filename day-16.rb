require_relative 'common'

require_relative 'day-16/models'
require_relative 'day-16/algorithms'

class Day16 < AdventDay
  EXPECTED_RESULTS = { 1 => 1651, 2 => 1707 }

  ELEPHANT_TEACHING_DURATION = 4
  MINUTES_BEFORE_ERUPTION = 30
  START_VALVE_NAME = "AA"

  def first_part(optimize: true)
    search = valves
    search = optimize(search) if optimize

    start = search.find { |v| v.name == START_VALVE_NAME }

    path = optimal_moves(start)
    total_pressure(path)[:pressure]

    # args = State.new({
    #   actors: Set.new([
    #     Actor.new(name: 'Human', position: start, path: [], time: MINUTES_BEFORE_ERUPTION),
    #   ]),
    #   remaining_valves: Set.new(valves),
    #   pressure: 0,
    # })
    # bfs_elephant_moves(args)
  end

  def display_path(path)
    puts path.map(&:inspect)
  end

  def second_part
    # bfs_second # Works but not performant enough
    dfs_second
  end

  private

  # Fully modelized
  def bfs_second
    start = valves.find { |v| v.name == START_VALVE_NAME }
    remaining_time = MINUTES_BEFORE_ERUPTION - ELEPHANT_TEACHING_DURATION

    args = State.new({
      actors: Set.new([
        Actor.new(name: 'Human', position: start, path: [], time: remaining_time),
        Actor.new(name: 'Elephant', position: start, path: [], time: remaining_time),
      ]),
      remaining_valves: Set.new(valves),
      pressure: 0,
    })

    bfs_elephant_moves(args).pressure
  end

  # Not fully moelized for performance
  def dfs_second(low_object: false)
    start = valves.find { |v| v.name == START_VALVE_NAME }
    remaining_time = MINUTES_BEFORE_ERUPTION - ELEPHANT_TEACHING_DURATION

    if low_object
      res = low_objects_dfs(start, start, time: remaining_time) # Even fewer objects to go even faster
      res.flatten.max
    else
      res = dfs_elephant_moves(start, start, time: remaining_time)
      res.values.max
    end
  end

  def optimal_moves(current_valve, time: MINUTES_BEFORE_ERUPTION, open_valves: Set.new, cache: {})
    return [] if time <= 0

    cache_key = [current_valve.hash, time, open_valves.map(&:hash).sort]

    cache[cache_key] ||= begin
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
      max
    end
  end

  def total_pressure(moves)
    moves.each_with_object({rate: 0, pressure: 0}) do |action, result|
      result[:pressure] += result[:rate] * action.time_cost
      result[:rate] += action.opens_valve&.flow_rate || 0
    end
  end

  FORMAT = /Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? (.*)/
  def convert_data(data)
    super.map.with_index do |valve, index|
      info = valve.match(FORMAT)&.captures
      raise "Bad valve format" unless info
      Valve.new(name: info[0], index: index, flow_rate: info[1].to_i, neighbors: info[2].split(', '))
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
