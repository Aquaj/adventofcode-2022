require_relative 'common'

class Day9 < AdventDay
  EXPECTED_RESULTS = { 1 => 13, 2 => 36 }

  def first_part
    positions = { tail: [0,0], head: [0,0] }
    tail_history = Set.new.tap { |s| s << positions[:tail] }
    moves.each do |(direction, duration)|
      duration.times do
        # Move head
        positions[:head] = move_in(direction, positions[:head])

        # Move tail
        if !adjacent?(positions[:head], positions[:tail])
          new_coords = move_towards(positions[:tail], positions[:head])
          positions[:tail] = new_coords
        end

        tail_history << positions[:tail].dup
      end
    end
    tail_history.size
  end

  def second_part
    rope = [:head, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    positions = rope.map { |knot| [knot, [0,0]] }.to_h

    tail_history = Set.new.tap { |s| s << positions[rope.last] }

    moves.each do |(direction, duration)|
      duration.times do
        # Move head
        positions[:head] = move_in(direction, positions[:head])

        # Move tail
        rope.each_cons(2) do |previous, knot|
          prev_pos = positions[previous]
          knot_pos = positions[knot]

          if !adjacent?(prev_pos, knot_pos)
            new_coords = move_towards(knot_pos, prev_pos)
            positions[knot] = new_coords
          end
        end

        tail_history << positions[rope.last].dup
      end
    end
    tail_history.size
  end

  private

  def adjacent?(pos1, pos2)
    x1,y1 = *pos1
    x2,y2 = *pos2
    (x1 - x2).abs <= 1 && (y1 - y2).abs <= 1
  end

  def move_towards(curr, dest)
    x1,y1 = curr
    x2,y2 = dest

    direction = x2 <=> x1
    new_x1 = x1 + direction
    direction = y2 <=> y1
    new_y1 = y1 + direction

    [new_x1, new_y1]
  end

  def move_in(direction, orig_pos)
    x,y = *orig_pos

    case direction
    when 'U' then [x, y+1]
    when 'R' then [x+1, y]
    when 'L' then [x-1, y]
    when 'D' then [x, y-1]
    end
  end

  def convert_data(data)
    super.map do |move|
      direction, duration = *move.split
      [direction, duration.to_i]
    end
  end
  alias_method :moves, :input

  def debug_input
    path = "#{input_fetcher.debug_file_path}-#{part}"
    File.read(path)
  end
end

Day9.solve if __FILE__ == $0
