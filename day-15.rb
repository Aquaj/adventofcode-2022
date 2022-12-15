require_relative 'common'

class Day15 < AdventDay
  EXPECTED_RESULTS = { 1 => 26, 2 => nil }

  def first_part
    taken_spots = sensors_info.flatten(1).
      select { |(_,y)| y == studied_row }.
      map(&:first).uniq

    segments = sensors_info.map do |((sx,sy), beacon)|
      distance_to_row = (sy - studied_row).abs
      distance_to_beacon = distance_between([sx,sy],beacon)
      remainder = distance_to_beacon - distance_to_row

      next unless remainder.positive?

      [sx - remainder, sx + remainder]
    end

    merge_down(segments).map do |(s,f)|
      beacons_and_sensors_in_segment =  taken_spots.count { |o| o >= s && o <= f }
      length = f - s + 1 # + 1 because we count both extremities
      length - beacons_and_sensors_in_segment
    end.sum
  end

  def second_part
  end

  private

  def distance_between(source, target)
    source.zip(target).map { |pair| pair.reduce(&:-).abs }.sum
  end

  def merge_down(segments)
    segments.compact.sort.each_with_object([]) do |segment, merged|
      last = merged.last
      start, finish = last || []

      if last && (start <= segment[0] && segment[0] <= finish)
        last[-1] = [finish, segment[-1]].max
      else
        merged << segment
      end
    end
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
