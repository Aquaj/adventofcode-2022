require_relative 'common'

class Day3 < AdventDay
  EXPECTED_RESULTS = { 1 => 157, 2 => 70 }

  GROUP_SIZE = 3

  def first_part
    rucksacks.sum do |rucksack|
      priority_of(shared_item_in(compartments_of(rucksack)))
    end
  end

  def second_part
    rucksacks.each_slice(GROUP_SIZE).sum do |group|
      priority_of(shared_item_in(group))
    end
  end

  private

  # Lowercase item types a through z have priorities 1 through 26.
  # Uppercase item types A through Z have priorities 27 through 52.
  def priority_of(item)
    [*('a'..'z'), *('A'..'Z')].index(item) + 1
  end

  def shared_item_in(collections)
    collections.map(&:chars).reduce(&:&).unwrap
  end

  def compartments_of(rucksack)
    midpoint = rucksack.length / 2
    [rucksack[0...midpoint], rucksack[midpoint..-1]]
  end

  def convert_data(data)
    super
  end
  alias_method :rucksacks, :input
end

Day3.solve if __FILE__ == $0
