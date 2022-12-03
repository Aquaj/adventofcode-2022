require_relative 'common'

class Day3 < AdventDay
  EXPECTED_RESULTS = { 1 => 157, 2 => nil }

  def first_part
    input.map { |ruck| [ruck[0...(ruck.length / 2)], ruck[(ruck.length / 2)..-1]] }.sum do |first_c, last_c|
      common = (first_c.chars.uniq & last_c.chars.uniq)
      [*('a'..'z'), *('A'..'Z')].index(common.unwrap) + 1
    end
  end

  def second_part
  end

  private

  def convert_data(data)
    super
  end
end

Day3.solve
