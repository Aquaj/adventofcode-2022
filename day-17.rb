require_relative 'common'

class Day17 < AdventDay
  EXPECTED_RESULTS = { 1 => 3068, 2 => nil }

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
  ROCKS_TO_FALL = 2022

  def first_part
    infinite_rocks = rock_shapes.cycle

    summit = 0 # Floor
    state = Set.new
    high_point = infinite_rocks.each_with_index.each_with_object(jets.cycle) do |(rock, index), jetlist|
      break summit if index == ROCKS_TO_FALL

      previous_coords = nil
      coords = move(rock, Vector[2, summit + 3])

      while coords do
        move = jetlist.next

        new_coords = move(coords, move)

        wall_intersection = new_coords.any? { |coord| (coord[0] < 0) || (coord[0] > CHAMBER_WIDTH - 1) }
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

      summit = state.map { |coord| coord[1] }.max + 1
    end
  end

  def second_part
  end

  private

  def render(state, rock: Set.new)
    min_x, max_x = (state + rock).map { |s| s[0] }.minmax
    min_y, max_y = (state + rock).map { |s| s[1] }.minmax

    min_x = [min_x, 0].min
    max_x = [max_x, CHAMBER_WIDTH - 1].max

    min_y = [min_y, 0].min
    max_y = [max_y, 3].max

    max_y.downto(min_y) do |y|
      row = min_x.upto(max_x).map do |x, line|
        pos = Vector[x,y]
        character = '.'
        character = '#' if state.include? pos
        character = '@' if rock.include? pos
        character
      end.join
      puts "|#{row}|"
    end
    puts '+'+ '-'*(max_x-min_x+1) +'+'
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
    rock.map { |coord| coord + vector }.to_set rescue byebug
  end

  def shape_matrix(shape)
    lines = shape.split("\n")
    lines.map.with_index do |row, y|
      row.chars.filter_map.with_index { |col, x| col == '#' ? Vector[x,lines.count-y-1] : nil }
    end.flatten
  end
end

Day17.solve
