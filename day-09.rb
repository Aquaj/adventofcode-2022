require_relative 'common'

class Day9 < AdventDay
  EXPECTED_RESULTS = { 1 => 13, 2 => nil }

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
