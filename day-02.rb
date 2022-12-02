require_relative 'common'

class Day2 < AdventDay
  EXPECTED_RESULTS = { 1 => 15 }

  OPPONENT_MOVES = { 'A' => :rock, 'B' => :paper, 'C' => :scissors }
  MY_MOVES = { 'X' => :rock, 'Y' => :paper, 'Z' => :scissors }

  WINNING_MOVES = [
    [:paper, :rock],
    [:scissors, :paper],
    [:rock, :scissors],
  ].freeze
  LOSING_MOVES = WINNING_MOVES.map(&:reverse).freeze

  def first_part
    first_part_rounds.sum do |(opponent_move, my_move)|
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

  def first_part_rounds
    instructions.map do |(opponent_move, my_move)|
      [OPPONENT_MOVES[opponent_move], MY_MOVES[my_move]]
    end
  end

  def winner(move_a, move_b)
    case
    when WINNING_MOVES.include?([move_a, move_b]) then 0
    when LOSING_MOVES.include?([move_a, move_b]) then 1
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
    super.map(&:split)
  end
  alias_method :instructions, :input
end

Day2.solve
