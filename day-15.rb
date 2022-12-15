require_relative 'common'

class Day15 < AdventDay
  EXPECTED_RESULTS = { 1 => 26, 2 => nil }

  def first_part
    distances = sensors_info.map do |sensor, beacon|
      [sensor, { beacon: beacon, distance: distance_between(sensor,beacon) }]
    end.to_h

    distances.map do |(sx,sy), info|
      distance_to_row = (sy - studied_row).abs
      next Set.new if distance_to_row > info[:distance]
      remainder = info[:distance] - distance_to_row

      sensor = sx if sy == studied_row
      beacon = info[:beacon][0] if info[:beacon][1] == studied_row
      ((sx - remainder)..(sx + remainder)).to_set - [sensor, beacon]
    end.reduce(&:|).count
  end

  def second_part
  end

  private

  def detected_by?(sensor, coords:)
    sensor_pos, info = sensor
    distance_between(sensor_pos, coords) <= info[:distance]
  end

  def distance_between(source, target)
    source.zip(target).map { |pair| pair.reduce(&:-).abs }.sum
  end

  def studied_row
    debug? ? 10 : 2_000_000
  end

  def convert_data(data)
    super.map do |sensor_info|
      info = sensor_info.match(/Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/)&.captures
      raise "Invalid sensor info" unless info
      [[info[0].to_i, info[1].to_i], [info[2].to_i, info[3].to_i]]
    end.to_h
  end
  alias_method :sensors_info, :input
end

Day15.solve
