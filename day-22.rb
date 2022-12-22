require_relative 'common'

class Day22 < AdventDay
  EXPECTED_RESULTS = { 1 => 6032, 2 => nil }

  class Map < Grid
    OUT = ' '
    WALL = '#'
    FREE = '.'

    def up(x,y)
      new_y = (y - 1) % self.height
      new_y = (new_y - 1) % self.height while out_of_bounds?(x, new_y)
      return nil if self[x,new_y] == WALL
      [x,new_y]
    end

    def down(x,y)
      new_y = (y + 1) % self.height
      new_y = (new_y + 1) % self.height while out_of_bounds?(x, new_y)
      return nil if self[x,new_y] == WALL
      [x,new_y]
    end

    def left(x,y)
      new_x = (x - 1) % self.width
      new_x = (new_x - 1) % self.width while out_of_bounds?(new_x, y)
      return nil if self[new_x,y] == WALL
      [new_x,y]
    end

    def right(x,y)
      new_x = (x + 1) % self.width
      new_x = (new_x + 1) % self.width while out_of_bounds?(new_x, y)
      return nil if self[new_x,y] == WALL
      [new_x,y]
    end

    def out_of_bounds?(x,y)
      super || self[y][x] == OUT
    end
  end

  ROTATION = { 'R' => 1, 'L' => -1 }
  DIRECTIONS = %i[right down left up]

  DISPLAY = { up: '^', down: 'v', right: '>', left: '<' }

  def first_part
    map = input[:map]

    initial_coords = [map[0].index(Map::FREE), 0]
    state = { pos: initial_coords, facing: 0 }
    input[:directions].each_slice(2).each_with_object(state) do |(move, rot), current|
      move.times do
        direction = DIRECTIONS[state[:facing]]

        map[*current[:pos]] = DISPLAY[direction]
        new_pos = map.send(direction, *state[:pos])
        break unless new_pos

        state[:pos] = new_pos
      end
      state[:facing] = (state[:facing] + ROTATION[rot]) % 4 if rot
    end

    x, y = state[:pos]
    (y+1) * 1000 + (x+1) * 4 + state[:facing]
  end

  def second_part
  end

  private

  def convert_data(data)
    map, directions = data.split("\n\n")

    map = map.split("\n").then do |lines|
      lines.map { |line| line.ljust(lines.map(&:length).max, ' ').chars }
    end.then { |chars| Map.new(chars) }

    directions = directions.strip.scan(/(\d+|\D+)/).flatten.map { |dir| dir.to_i.to_s == dir ? dir.to_i : dir }

    { map: map, directions: directions }
  end
end

Day22.solve
