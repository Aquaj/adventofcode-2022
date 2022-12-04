require_relative 'common'

class Day4 < AdventDay
  EXPECTED_RESULTS = { 1 => 2, 2 => nil }

  def first_part
    input.count { |s1,s2| s1.cover?(s2) || s2.cover?(s1) }
  end

  def second_part
  end

  private

  def convert_data(data)
    super.map do |assign|
      assign.split(',').map { |sec| sec.split('-').then { |(s,e)| (s.to_i..e.to_i) } }
    end
  end
end

Day4.solve
