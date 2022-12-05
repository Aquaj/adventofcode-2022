require_relative 'common'

class Day5 < AdventDay
  def first_part
    input[:instructions].each_with_object(input[:crates].dup) do |(how_many, from, to), crates|
      to_move = how_many.times.map { crates[from - 1].shift }
      to_move.each { |crate| crates[to - 1].unshift crate }
    end.map(&:first).join
  end

  def second_part
  end

  private

  def convert_data(data)
    crates, instructions = data.split("\n\n")
    *crates, _labels = crates.split("\n")
    crates = crates.map do |row|
      row.chars.each_slice(4).to_a.map { |crate| crate.join.strip[1] }
    end.transpose.map(&:compact)
    instructions = instructions.split("\n").map { |ins| ins.match(/move (\d+) from (\d+) to (\d+)/).captures.map(&:to_i) }
    { crates: crates, instructions: instructions }
  end
end

Day5.solve
