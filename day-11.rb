require_relative 'common'

class Day11 < AdventDay
  EXPECTED_RESULTS = { 1 => 10605, 2 => nil }

  INSPECTION_ROUNDS = 20
  def first_part
    final_monkeys = INSPECTION_ROUNDS.times.each_with_object(monkeys.dup) do |_, monkeys|
      monkeys.each do |_index, monkey|
        monkey[:items].each do |worry_level|
          worry_level = monkey[:operation].call worry_level
          worry_level /= 3
          test = monkey[:throw][:condition].call worry_level
          target = monkeys[monkey[:throw][test]]
          target[:items] << worry_level
          monkey[:inspections] += 1
        end
        monkey[:items] = []
      end
    end
    final_monkeys.values.map { |monkey| monkey[:inspections] }.sort.last(2).reduce(&:*)
  end

  def second_part
  end

  private

  def convert_data(data)
    monkeys = data.split("\n\n")

    monkeys.map.with_index { |m,i| [i, parse_monkey(m)] }.to_h
  end
  alias_method :monkeys, :input

  def parse_monkey(monkey)
    name, start, op, test, if_true, if_false = *monkey.split("\n")

    {
      index: parse_index(name),
      inspections: 0,
      items: parse_items(start),
      operation: parse_operation(op),
      throw: {
        condition: parse_condition(test),
        true => parse_destination_true(if_true),
        false => parse_destination_false(if_false),
      }
    }
  end

  def parse_index(line) =
    line.match(/Monkey (\d+)/).captures.first.to_i
  def parse_items(line) =
    line.match(/Starting items:((?: (?:\d+),?)*)/).captures.first.split(',').map(&:strip).map(&:to_i)
  def parse_operation(line) =
    lambda_for_operation line.match(/Operation: new = (((old|[-\*+]|\d+|) ?)+)$/).captures.first
  def parse_condition(line) =
    lambda_for_condition line.match(/Test: (.+)$/).captures.first
  def parse_destination_true(line) =
    line.match(/If true: throw to monkey (\d+)/).captures.first.to_i
  def parse_destination_false(line) =
    line.match(/If false: throw to monkey (\d+)/).captures.first.to_i

  def lambda_for_operation(operation) =
    -> (old) { eval(operation) }
  def lambda_for_condition(condition) =
    case condition
    when /divisible by (\d+)/
      divide_by = $LAST_MATCH_INFO.captures.first.to_i
      -> (value) { value % divide_by == 0 }
    end
end

Day11.solve
