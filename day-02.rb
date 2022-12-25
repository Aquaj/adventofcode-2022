require_relative 'common'

class Day2 < AdventDay
  EXPECTED_RESULTS = { 1 => 15, 2 => 12 }

  OPPONENT_MOVES = { 'A' => :rock, 'B' => :paper, 'C' => :scissors }
  MY_MOVES = { 'X' => :rock, 'Y' => :paper, 'Z' => :scissors }
  RESULTS = { 'X' => :lose, 'Y' => :draw, 'Z' => :win }

  WINNING_MOVES = [
    [:paper, :rock],
    [:scissors, :paper],
    [:rock, :scissors],
  ].freeze
  LOSING_MOVES = WINNING_MOVES.map(&:reverse).freeze

  def first_part
    instructions.sum do |(opponent_move, instruction)|
      opponent_move = OPPONENT_MOVES[opponent_move]
      my_move = MY_MOVES[instruction]

      result = winner(opponent_move, my_move)

      round_points(result) + points_for(my_move)
    end
  end

  def second_part
    instructions.sum do |(opponent_move, instruction)|
      result = RESULTS[instruction]

      opponent_move = OPPONENT_MOVES[opponent_move]
      my_move = case result
      when :draw then opponent_move
      when :lose then LOSING_MOVES.find { |pairs| pairs.last == opponent_move }.first
      when :win  then WINNING_MOVES.find { |pairs| pairs.last == opponent_move }.first
      end

      round_points(result) + points_for(my_move)
    end
  end

  private

  def winner(move_a, move_b)
    case
    when WINNING_MOVES.include?([move_a, move_b]) then :win
    when LOSING_MOVES.include?([move_a, move_b]) then :lose
    else :draw
    end
  end

  def round_points(result)
    case result
    when :lose then 0
    when :draw then 3
    when :win  then 6
    end
  end

  def points_for(move)
    case move
    when :rock     then 1
    when :paper    then 2
    when :scissors then 3
    end
  end

  def convert_data(data)
    super.map(&:split)
  end
  alias_method :instructions, :input
end

Day2.solve if __FILE__ == $0
