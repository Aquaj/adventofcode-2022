require_relative 'common'

class Day17 < AdventDay
  EXPECTED_RESULTS = { 1 => 3068, 2 => 1514285714288 }

  SHAPES = <<~SHAPES.split("\n\n")
    ####

    .#.
    ###
    .#.

    ..#
    ..#
    ###

    #
    #
    #
    #

    ##
    ##
  SHAPES
  CHAMBER_WIDTH = 7

  X = 0
  Y = 1

  def first_part
    find_height 2022
  end

  def second_part
    find_height 1_000_000_000_000
  end

  private

  def find_height(rocks_to_fall)
    infinite_rocks = rock_shapes.cycle

    cache = {}
    state = { jet_pos: 0, state: Set.new, height: 0 }
    height = 0
    infinite_rocks.each_with_index do |rock, index|

      # In case we actually reach the end before we can get mathy
      height += state[:height]
      summit = state[:state].map { |c| c[Y] }.max || 0
      break summit + height + 1 if index == rocks_to_fall

      cache_key = [rock.object_id, state[:jet_pos], state[:state]]
      if cache[cache_key].nil? # Unknown state => process and save it
        to_save = process_rock(rock, state[:jet_pos], state[:state])

        to_save[:index] = index # Useful to_identify the cache loop, see below

        # Compacting state to maximize cache reuse
        state = cache[cache_key] ||= compact(to_save)
      else
        # Given a state S1, S2 = process(S1), and the fact rocks are in order
        # if we hit the cache it means we are looping:
        #
        #   process(Sn) -> S1, process(S1) -> S2,
        #     ...,
        #     process(Sk) -> Sk+1, process(SK+1) -> SK+2,
        #     ...
        #     process(Sn-1) -> Sn, process(Sn) -> Sk,
        #     process(Sk) -> Sk+1, and so on
        #
        # So we can now just find the total height by summing:
        # - the height from before it loops, with
        # - the added height by each state in the loop
        #     * the number of times the loop occurred, plus
        # - the height gained by the last, partial run of the loop, and
        # - the summit of the last state.

        loop_start = cache[cache_key]
        loop_body, loop_setup = cache.partition{ |_,state| state[:index] >= loop_start[:index] }.map do |entries|
          entries.map(&:last).sort_by { |s| s[:index] }
        end

        occurrences, last_run_length = (rocks_to_fall - loop_setup.size).divmod(loop_body.size)

        setup_height = loop_setup.sum { |s| s[:height] }
        body_height = loop_body.sum { |state| state[:height] } * occurrences

        last_run = loop_body[0...last_run_length]
        last_run_height = last_run.sum { |s| s[:height] }

        last_state = last_run.last
        summit = last_state[:state].map { |c| c[Y] }.max + 1

        break setup_height + body_height + last_run_height + summit
      end
    end
  end

  def process_rock(rock, jet_pos, state)
    highest_point = state.map { |c| c[Y] }.max
    summit = (highest_point && highest_point + 1) || 0
    coords = move(rock, Vector[2, summit + 3])

    while coords do
      move = jets[jet_pos]
      jet_pos = (jet_pos + 1) % jets.length

      # render state, rock: coords
      new_coords = move(coords, move)

      wall_intersection = new_coords.any? { |coord| (coord[X] < 0) || (coord[X] > CHAMBER_WIDTH - 1) }
      unless state.intersect?(new_coords) || wall_intersection
        coords = new_coords
      end

      new_coords = move(coords, Vector[0,-1])
      floor_intersection = new_coords.any? { |coord| coord[1] < 0 }
      if state.intersect?(new_coords) || floor_intersection
        state += coords
        coords = nil
      else
        coords = new_coords
      end
    end

    { jet_pos: jet_pos, state: state }
  end

  def compact(to_compact)
    state = to_compact.deep_copy
    local_summit = state[:state].map{|c| c[Y]}.max

    # Finding "cutoffs" in the chamber which no rock can fall below
    search_window = 2
    blocking = local_summit.towards(0).each_cons(search_window).find do |ys|
      (0...CHAMBER_WIDTH).all? do |x|
        ys.any? { |y| state[:state].include? Vector[x,y] }
      end
    end

    # Compacting down by removing excess coordinates,
    # then moving the remainder coordinates to match.
    if blocking
      level = blocking.min
      reduced_state = state[:state].select { |c| c[Y] >= level }
      levelled_state = move(reduced_state, Vector[0, -level])
      state[:state] = levelled_state
    end

    # Storing the info for computation into `:height`
    state[:height] = level.to_i

    state
  end

  def render(state, rock: Set.new)
    min_x, max_x = (state + rock).map { |s| s[X] }.minmax
    min_y, max_y = (state + rock).map { |s| s[Y] }.minmax

    min_x = [min_x, 0].compact.min
    max_x = [max_x, CHAMBER_WIDTH - 1].compact.max

    min_y = [min_y, 0].compact.min
    max_y = [max_y, 3].compact.max

    max_y.downto(min_y) do |y|
      row = min_x.upto(max_x).map do |x, line|
        pos = Vector[x,y]
        character = '.'
        character = '#' if state.include? pos
        character = '@' if rock.include? pos
        character
      end.join
      puts "     |#{row}|"
    end
    puts "#{min_x}".rjust(4) + ' +'+ '-'*(max_x-min_x+1) +'+'
    puts
  end

  MOVES = {
    '>' => Vector[1,0],
    '<' => Vector[-1,0],
  }
  def convert_data(data)
    data.strip.chars.map { |c| MOVES[c] }
  end
  alias_method :jets, :input

  def rock_shapes
    @rock_shapes ||= SHAPES.map { |shape| shape_matrix(shape) }
  end

  def move(rock, vector)
    vector = Vector[*vector] unless vector.is_a? Vector
    rock.map { |coord| coord + vector }.to_set
  end

  def shape_matrix(shape)
    lines = shape.split("\n")
    lines.map.with_index do |row, y|
      row.chars.filter_map.with_index { |col, x| col == '#' ? Vector[x,lines.count-y-1] : nil }
    end.flatten
  end
end

Day17.solve
