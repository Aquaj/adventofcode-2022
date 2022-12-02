require_relative 'common'

class Day1 < AdventDay
  EXPECTED_RESULTS = { 1 => 24000, 2 => 45000 }

  def first_part
    elves.map(&:sum).max
  end

  def second_part
    elves.map(&:sum).sort.last(3).sum
  end

  private

  def convert_data(data)
    data.
      split("\n\n").
      map { |group| group.split("\n").map(&:to_i) }
  end
  alias_method :elves, :input
end

Day1.solve
