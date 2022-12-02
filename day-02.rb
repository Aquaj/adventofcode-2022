require_relative 'common'

class Day2 < AdventDay
  EXPECTED_RESULTS = { 1 => 15 }

  OPPONENT_MOVES = {
    'A' => :rock,
    'B' => :paper,
    'C' => :scissors,
  }
  MY_MOVES = {
    'X' => :rock,
    'Y' => :paper,
    'Z' => :scissors,
  }

  def first_part
    rounds.sum do |(opponent_move, my_move)|
      round_points = case winner(opponent_move, my_move)
      when 0  then 0 # lose
      when 1  then 6 # win
      when -1 then 3 # draw
      end
      round_points + points_for(my_move)
    end
  end

  def second_part
  end

  private

  def winner(move_a, move_b)
    case
    when move_a == :paper && move_b == :rock     then 0
    when move_a == :scissors && move_b == :paper then 0
    when move_a == :rock && move_b == :scissors  then 0

    when move_a == :rock && move_b == :paper     then 1
    when move_a == :paper && move_b == :scissors then 1
    when move_a == :scissors && move_b == :rock  then 1

    else -1

    end
  end

  def points_for(move)
    case move
    when :rock then 1
    when :paper then 2
    when :scissors then 3
    end
  end

  def convert_data(data)
    super.map do |rounds|
      opponent_move, my_move = rounds.split
      [OPPONENT_MOVES[opponent_move], MY_MOVES[my_move]]
    end
  end
  alias_method :rounds, :input
end

Day2.solve
