require_relative 'common'

class Day20 < AdventDay
  EXPECTED_RESULTS = { 1 => 3, 2 => nil }

  def first_part
    list = LinkedList.new(file)
    instructions = list.links.dup

    list.last.tail = list.first # Closing the loop
    list.first.head = list.last # Closing the loop

    instructions.each do |instruction|
      move_by = instruction.value
      list.move(instruction, move_by, loop: true)
    end

    positions = [1000, 2000, 3000]
    zero = list.find { |v,_| v == 0 }.last
    positions.map { |p| zero.next(p).value }.sum
  end

  def second_part
  end

  private

  def convert_data(data)
    super.map(&:to_i)
  end
  alias_method :file, :input
end

Day20.solve
