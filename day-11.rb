require_relative 'common'

class Day11 < AdventDay
  EXPECTED_RESULTS = { 1 => 10605, 2 => 2713310158 }

  def first_part
    final_monkeys = rounds.times.reduce(monkeys.dup) { |monkeys, _| play_round(monkeys) }
    final_monkeys.values.map { |monkey| monkey[:inspections] }.sort.last(2).reduce(&:*)
  end

  def second_part
    final_monkeys = rounds.times.reduce(monkeys.dup) { |monkeys, _| play_round(monkeys) }
    final_monkeys.values.map { |monkey| monkey[:inspections] }.sort.last(2).reduce(&:*)
  end

  private

  def rounds
    @part == 1 ? 20 : 10000
  end

  def play_round(monkeys)
    monkeys.each do |_index, monkey|
      monkey[:items].each do |worry_level|
        worry_level = monkey[:operation].call worry_level
        case @part
        when 1 then worry_level /= 3
        when 2 then worry_level %= all_tests
        end

        test = worry_level % monkey[:throw][:test] == 0
        target = monkeys[monkey[:throw][test]]
        target[:items] << worry_level
        monkey[:inspections] += 1
      end
      monkey[:items] = []
    end
    monkeys
  end

  def all_tests
    @reductor ||= monkeys.map { |_,m| m[:throw][:test] }.reduce(&:*)
  end

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
        test: parse_test(test),
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
  def parse_test(line) =
    line.match(/Test: divisible by (\d+)$/).captures.first.to_i
  def parse_destination_true(line) =
    line.match(/If true: throw to monkey (\d+)/).captures.first.to_i
  def parse_destination_false(line) =
    line.match(/If false: throw to monkey (\d+)/).captures.first.to_i

  def lambda_for_operation(operation) =
    -> (old) { eval(operation) }
end

Day11.solve
