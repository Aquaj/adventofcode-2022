require_relative 'common'

class Day6 < AdventDay
  EXPECTED_RESULTS = { 1 => 7, 2 => 19 }

  def first_part
    stream = input.each_cons(4)
    place = 4
    chars = stream.next
    until chars.uniq.size == chars.size
      place += 1
      chars = stream.next
    end
    place
  end

  def second_part
  end

  private

  def convert_data(data)
    super.unwrap.chars
  end
end

Day6.solve
