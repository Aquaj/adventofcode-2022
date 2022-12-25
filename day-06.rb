require_relative 'common'

class Day6 < AdventDay
  EXPECTED_RESULTS = { 1 => 7, 2 => 19 }

  def first_part
    stream = input.each_cons(4)
    place = stream.next.size
    place += 1 until stream.next.then { |data| data.uniq.size == data.size }
    place + 1
  end

  def second_part
    stream = input.each_cons(14)
    place = stream.next.size
    place += 1 until stream.next.then { |data| data.uniq.size == data.size }
    place + 1
  end

  private

  def convert_data(data)
    super.unwrap.chars
  end
end

Day6.solve if __FILE__ == $0
