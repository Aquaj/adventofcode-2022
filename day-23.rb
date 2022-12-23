require_relative 'common'

class Day23 < AdventDay
  EXPECTED_RESULTS = { 1 => 110, 2 => nil }

  SUGGESTIONS = %i[N S E W]
  BLOCKERS = {
    N: %i[NE N NW],
    S: %i[SE S SW],
    E: %i[SE E NE],
    W: %i[SW W NW],
  }
  def first_part
    @elves = elves
    current_priority = 0

    10.times do
      priorities = (SUGGESTIONS * 2)[current_priority, SUGGESTIONS.length]
      suggestions = @elves.map do |elf|
        next [elf, nil] if OFFSETS.none? { |_,offset| @elves.include? (Vector[*elf] + offset).to_a }
        move = priorities.find { |move| new_pos = new_position(elf, move); break new_pos if new_pos }
        [elf, move]
      end
      moves, static = suggestions.partition { |suggestion| suggestion.last && suggestions.count { |s| s.last == suggestion.last } == 1 }
      @elves = (moves.map(&:last) + static.map(&:first)).to_set
      current_priority = (current_priority + 1) % SUGGESTIONS.length
    end

    min_x, max_x = @elves.map { |(x,_)| x }.minmax
    min_y, max_y = @elves.map { |(_,y)| y }.minmax
    (max_x - min_x + 1) * (max_y - min_y + 1) - @elves.count
  end

  def second_part
  end

  private

  def render(set)
    min_x, max_x = @elves.map { |(x,_)| x }.minmax
    min_y, max_y = @elves.map { |(_,y)| y }.minmax
    (min_y..max_y).each do |y|
      l = ''
      (min_x..max_x).each do |x|
        l << (@elves.include?([x,y]) ? '#' : '.')
      end
      puts l
    end
    puts
  end

  OFFSETS = {
    NE: Vector[-1, -1],
    N:  Vector[0,  -1],
    NW: Vector[1,  -1],
    SE: Vector[-1, 1],
    S:  Vector[0,  1],
    SW: Vector[1,  1],
    E:  Vector[-1, 0],
    W:  Vector[1,  0],
  }
  def new_position(elf, direction)
    blocked = BLOCKERS[direction].any? do |block|
      block_pos = OFFSETS[block] + Vector[*elf] rescue byebug
      @elves.include? block_pos.to_a
    end
    blocked ? nil : (Vector[*elf] + OFFSETS[direction]).to_a
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
