require_relative 'common'

class Day23 < AdventDay
  EXPECTED_RESULTS = { 1 => 110, 2 => 20 }

  SUGGESTIONS = %i[N S E W]
  BLOCKERS = {
    N: %i[NE N NW],
    S: %i[SE S SW],
    E: %i[SE E NE],
    W: %i[SW W NW],
  }
  def first_part
    elves = input.deep_copy
    priority = 0

    10.times do
      priorities = (SUGGESTIONS * 2)[priority, SUGGESTIONS.length]
      elves = play_round(elves, priorities: priorities)
      priority = (priority + 1) % SUGGESTIONS.length
    end

    min_x, max_x = elves.map(&:to_a).map { |(x,_)| x }.minmax
    min_y, max_y = elves.map(&:to_a).map { |(_,y)| y }.minmax
    (max_x - min_x + 1) * (max_y - min_y + 1) - elves.count
  end

  def second_part
    priority = 0
    elves = input.deep_copy

    (1..).each do |round|
      priorities = (SUGGESTIONS * 2)[priority, SUGGESTIONS.length]
      new_positions = play_round(elves, priorities: priorities)
      break round if elves == new_positions
      elves = new_positions
      priority = (priority + 1) % SUGGESTIONS.length
    end
  end

  private

  def play_round(to_move, priorities: SUGGESTIONS)
    suggestions = to_move.each_with_object({}) do |elf, moves|
      if OFFSETS.none? { |_,offset| to_move.include? add(elf, offset) }
        moves[nil] ||= { count: 0, elves: [] }
        moves[nil][:elves] << elf
        moves[nil][:count] += 1
        next
      end

      move = priorities.find { |move| new_pos = new_position(elf, move, elves: to_move); break new_pos if new_pos }

      moves[move] ||= { count: 0, elves: [] }
      moves[move][:elves] << elf
      moves[move][:count] += 1
    end

    undecided = suggestions.delete(nil)[:elves]
    suggestions.each_with_object(undecided) do |(move, data), moves|
      if data[:count] == 1
        moves << move
      else
        data[:elves].each { moves << _1 }
      end
    end.to_set
  end

  def add(pos1,pos2)
    x1,y1 = pos1
    x2,y2 = pos2
    [x1+x2, y1+y2]
  end

  def render(set)
    min_x, max_x = set.map(&:to_a).map { |(x,_)| x }.minmax
    min_y, max_y = set.map(&:to_a).map { |(_,y)| y }.minmax
    (min_y..max_y).each do |y|
      l = ''
      (min_x..max_x).each do |x|
        l << (set.include?([x,y]) ? '#' : '.')
      end
      puts l
    end
    puts
  end

  OFFSETS = {
    NE: [-1, -1],
    N:  [0,  -1],
    NW: [1,  -1],
    SE: [-1, 1],
    S:  [0,  1],
    SW: [1,  1],
    E:  [-1, 0],
    W:  [1,  0],
  }
  def new_position(elf, direction, elves:)
    blocked = BLOCKERS[direction].any? do |block|
      block_pos = add(OFFSETS[block], elf)
      elves.include? block_pos
    end
    blocked ? nil : add(elf, OFFSETS[direction])
  end

  def convert_data(data)
    super.flat_map.with_index do |row, y|
      row.chars.filter_map.with_index do |c, x|
        [x,y] if c == '#'
      end
    end.compact.to_set
  end
  alias_method :elves, :input
end

Day23.solve
