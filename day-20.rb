require_relative 'common'

class Day20 < AdventDay
  EXPECTED_RESULTS = { 1 => 3, 2 => 1623178306 }

  GROVE_COORDS_POS = [1000, 2000, 3000]

  def first_part
    list = LinkedList.new(file)
    instructions = list.links.dup

    list.last.tail = list.first # Closing the loop
    list.first.head = list.last # Closing the loop

    instructions.each do |instruction|
      move_by = instruction.value
      list.move(instruction, move_by, loop: true)
    end

    zero = list.find { |v,_| v == 0 }.last
    GROVE_COORDS_POS.map { |p| zero.next(p).value }.sum
  end

  DECRYPTION_KEY = 811589153

  def second_part
    list = LinkedList.new(file.map { |v| v * DECRYPTION_KEY })
    instructions = list.links

    list.last.tail = list.first # Closing the loop
    list.first.head = list.last # Closing the loop

    (instructions * 10).each do |instruction|
      move_by = instruction.value
      list.move(instruction, move_by, loop: true)
    end

    zero = list.find { |v,_| v == 0 }.last
    GROVE_COORDS_POS.map { |p| zero.next(p).value }.sum
  end

  private

  def convert_data(data)
    super.map(&:to_i)
  end
  alias_method :file, :input
end

Day20.solve
