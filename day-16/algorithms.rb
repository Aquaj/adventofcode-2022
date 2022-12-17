class Day16 < AdventDay
  # Using Bellman-Ford to remove all unncessary edges since
  # jammed valves are only used to travel and will never be stopped at
  # Note: we keep the jammed *nodes* in so the starting point can still enter
  # the graph.
  def optimize(valve_set)
    edges = valve_set.flat_map { |v| v.neighbors.map { |n,d| [v, n] } }
    graph = Graph.new(valve_set, edges)
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
  # For compatibility with Algorithms.bellman_ford
  Graph = Struct.new(:nodes, :edges) do
    def edge_cost(v,n)
      v.neighbors[n]
    end
  end

  # Not performant enough for anything other than the example input
  def bfs_elephant_moves(state, queue=Containers::PriorityQueue.new, discovered={})
    queue.push state, state.pressure
    best_state = state

    until queue.empty? do
      state = queue.pop
      next if state.ignore?

      all_valves_open = state.remaining_valves.empty?

      possible_moves = state.actors.
        map(&:available_actions).
        then { |h,*r| h.product(*r) }

      possible_moves.each do |moves|

        if all_valves_open
          # Nothing left to do, just wait
          next unless moves.all? { |m| m.action.is_a? WaitHere }
        else
          # Don't wait or backtrack when there's work left
          next if moves.all? { |m| m.action.is_a? WaitHere }
          next if moves.all?(&:loops?)
        end

        # Not enough time
        next if moves.any? { |move| move.finish_time.negative? }
        # Can't open valve a second time
        next if moves.filter_map(&:opened_valve).any? { |valve| !state[:remaining_valves].include?(valve) }
        # Can't both open the same valve
        next if moves.map(&:opened_valve).compact.then { |to_open| to_open.uniq.count != to_open.count }


        new_state = State.new(
          actors: moves.map(&:to_actor),
          remaining_valves: state.remaining_valves - moves.map(&:opened_valve).compact,
          pressure: state.pressure + moves.sum { |move| move.flow_increase * move.finish_time },
        )

        previous_solution = discovered[new_state.fingerprint]

        next if previous_solution && previous_solution.pressure >= new_state.pressure

        previous_solution&.ignore!
        discovered[new_state.fingerprint] = new_state

        # Everyone done
        if new_state.actors.all? { |actor| actor.done? }
          best_state = new_state if best_state.pressure < new_state.pressure
        else
          queue.push new_state, new_state.pressure
        end
      end
    end

    best_state
  end

  # For some reason, keeps returning *second-best* path
  def dfs_elephant_moves(human_valve, elephant_valve, time:,
    pressure: 0, open_valves: Set.new, cache: {}.with_default(-Float::INFINITY))

    return cache if time < 0

    theoretical_final_pressure = pressure + open_valves.sum(&:flow_rate) * time

    cache_key = [human_valve, elephant_valve, time]
    return cache if cache[cache_key] && cache[cache_key] >= theoretical_final_pressure
    cache[cache_key] = theoretical_final_pressure

    all_actions = human_valve.actions.product(elephant_valve.actions)

    all_actions.filter_map do |human_action, elephant_action|
      next if open_valves.include? human_action.opens_valve
      open_after_human = (open_valves + [human_action.opens_valve].compact)
      next if open_after_human.include? elephant_action.opens_valve
      open_after_both = (open_after_human + [elephant_action.opens_valve].compact)

      dfs_elephant_moves(
        human_action.move_to,
        elephant_action.move_to,
        pressure: pressure + open_valves.sum(&:flow_rate),
        time: time - 1,
        open_valves: open_after_both,
        cache: cache,
      )
    end

    cache
  end

  # Not *fast* but fast enough
  def low_objects_dfs(human_valve, elephant_valve, time: , pressure: 0, open_valves: Set.new,
    cache: Array.new(valves.count) { Array.new(valves.count) { Array.new(time + 1, -Float::INFINITY) } })
    # cache: Hash.new { |h,k| h[k] = Hash.new { |h2,k2| h2[k2] = Array.new(time + 1, -Float::INFINITY) } })

    return cache if time < 0

    increase_rate = open_valves.sum(&:flow_rate)
    theoretical_final_pressure = pressure + increase_rate * time

    return cache if cache[human_valve.index][elephant_valve.index][time] >= theoretical_final_pressure

    cache[human_valve.index][elephant_valve.index][time] = theoretical_final_pressure

    openable = ->(valve) { (!valve.jammed? && !open_valves.include?(valve)) }

    # Wait it out if all valves opened
    if valves.all? { |v| v.jammed? || open_valves.include?(v) }
      low_objects_dfs(human_valve, elephant_valve,
        time: time - 1,
        pressure: pressure+increase_rate,
        open_valves: open_valves,
        cache: cache)
    end

    # Human opening their valve, elephant moves
    if openable.(human_valve) && !(openable.(elephant_valve))
      elephant_valve.neighbors.each do |neighbor, _|
        low_objects_dfs(human_valve, neighbor,
          time: time - 1,
          pressure: pressure+increase_rate,
          open_valves: open_valves + [human_valve],
          cache: cache)
      end
    end

    # Elephant opening their valve, human moves
    if !openable.(human_valve) && openable.(elephant_valve)
      human_valve.neighbors.each do |neighbor, _|
        low_objects_dfs(neighbor, elephant_valve,
          time: time - 1,
          pressure: pressure+increase_rate,
          open_valves: open_valves + [elephant_valve],
          cache: cache)
      end
    end

    # Both travel
    human_valve.neighbors.each do |hneighbor, _|
      elephant_valve.neighbors.each do |eneighbor, _|
        low_objects_dfs(hneighbor, eneighbor,
          time: time - 1,
          pressure: pressure+increase_rate,
          open_valves: open_valves,
          cache: cache)
      end
    end

    # Open both
    if openable.(human_valve) && openable.(elephant_valve)
      low_objects_dfs(human_valve, elephant_valve,
        time: time - 1,
        pressure: pressure + increase_rate,
        open_valves: open_valves + [human_valve, elephant_valve],
        cache: cache)
    end

    cache
  end
end
