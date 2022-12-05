require_relative 'common'

class Day5 < AdventDay
  EXPECTED_RESULTS = { 1 => "CMZ", 2 => "MCD" }

  def first_part
    crates, instructions = *input

    result_stacks = instructions.each_with_object(crates.dup) do |(number, from, to), crates|
      to_move = remove_many(number, crates[from])
      to_move.each { |crate| add_one(crate, crates[to]) }
    end

    result_stacks.map(&:first).join
  end

  def second_part
    crates, instructions = *input

    result_stacks = instructions.each_with_object(crates.dup) do |(number, from, to), crates|
      to_move = remove_many(number, crates[from])
      add_many(to_move, crates[to])
    end

    result_stacks.map(&:first).join
  end

  private

  def remove_many(number, column) =
    number.times.map { column.shift }

  def add_one(crate, column) =
    column.unshift crate

  def add_many(crates, column) =
    crates.reverse_each { |crate| add_one(crate, column) }

  def convert_data(data)
    raw_crates, raw_instructions = data.split("\n\n")
    [parse_crates(raw_crates), parse_instructions(raw_instructions)]
  end

  def parse_crates(raw)
    cols = raw.split("\n").map(&:chars).transpose
    stacks = cols.select { |col| col.last != " " } # Removing aesthetic additions
    stacks.map { |(*stack, _label)| stack - [" "] } # Trimming off label and empty spaces
  end

  def parse_instructions(raw)
    instructions = raw.split("\n")
    instructions.map do |instruction|
      how_many, from, to = instruction.match(/move (\d+) from (\d+) to (\d+)/).captures
      [how_many.to_i, from.to_i - 1, to.to_i - 1] # 0-indexing
    end
  end
end

Day5.solve
