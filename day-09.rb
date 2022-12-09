require_relative 'common'

class Day9 < AdventDay
  EXPECTED_RESULTS = { 1 => 13, 2 => nil }

  def first_part
    positions = { tail: [0,0], head: [0,0] }
    tail_history = []
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

        non_adjacent = [positions[:head], positions[:tail]].transpose.map { |pos| pos.reduce(&:-).abs }.any? { |d| d > 1 }
        if non_adjacent
          # Move tail
          if xh > xt
            new_xt = xt + 1
          elsif xh < xt
            new_xt = xt - 1
          else
            new_xt = xt
          end
          if yh > yt
            new_yt = yt + 1
          elsif yh < yt
            new_yt = yt - 1
          else
            new_yt = yt
          end
          positions[:tail] = [new_xt, new_yt]
          tail_history << positions[:tail].dup
        end
      end
    end
    tail_history.uniq.count + 1
  end

  def second_part
  end

  private

  def convert_data(data)
    super.map do |move|
      direction, duration = *move.split
      [direction, duration.to_i]
    end
  end
  alias_method :moves, :input
end

Day9.solve
