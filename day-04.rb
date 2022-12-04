require_relative 'common'

class Day4 < AdventDay
  EXPECTED_RESULTS = { 1 => 2, 2 => 4 }

  def first_part
    assignments.count { |first, second| first.cover?(second) || second.cover?(first) }
  end

  def second_part
    assignments.count { |first, second| (first.to_a & second.to_a).any? }
  end

  private

  def convert_data(data)
    super.map do |assignments|
      first, second = assign.split(',')
      [first, second].map do |assignment|
        first_section, last_section = assignment.split('-')
        (first_section..last_section)
      end
    end
  end
  alias_method :assignments, :input
end

Day4.solve
