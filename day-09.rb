require_relative 'common'

class Day9 < AdventDay
  EXPECTED_RESULTS = { 1 => 88, 2 => 36 }

  def first_part
    positions = { tail: [0,0], head: [0,0] }
    tail_history = Set.new.tap { |s| s << positions[:tail] }
    moves.each do |(direction, duration)|
      duration.times do
        xh,yh = *positions[:head]
        xt,yt = *positions[:tail]

        # Move head
        case direction
        when 'U'
          positions[:head] = [xh, yh+1]
        when 'R'
          positions[:head] = [xh+1, yh]
        when 'L'
          positions[:head] = [xh-1, yh]
        when 'D'
          positions[:head] = [xh, yh-1]
        end

        if !adjacent?(positions[:head], positions[:tail])
          new_coords = move_towards(positions[:tail], positions[:head])
          positions[:tail] = new_coords
          tail_history << positions[:tail].dup
        end
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
        xh,yh = *positions[:head]
        case direction
        when 'U'
          positions[:head] = [xh, yh+1]
        when 'R'
          positions[:head] = [xh+1, yh]
        when 'L'
          positions[:head] = [xh-1, yh]
        when 'D'
          positions[:head] = [xh, yh-1]
        end

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

    if x2 > x1
      new_x1 = x1 + 1
    elsif x2 < x1
      new_x1 = x1 - 1
    else
      new_x1 = x1
    end

    if y2 > y1
      new_y1 = y1 + 1
    elsif y2 < y1
      new_y1 = y1 - 1
    else
      new_y1 = y1
    end

    [new_x1, new_y1]
  end

  def convert_data(data)
    super.map do |move|
      direction, duration = *move.split
      [direction, duration.to_i]
    end
  end
  alias_method :moves, :input
end

Day9.solve
