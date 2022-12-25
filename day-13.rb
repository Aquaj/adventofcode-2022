require_relative 'common'

class Day13 < AdventDay
  EXPECTED_RESULTS = { 1 => 13, 2 => 140 }

  def first_part
    packet_pairs.filter_map.with_index do |pair, index|
      index + 1 if compare(*pair)
    end.sum
  end

  DIVIDER_PACKETS = [ [[2]], [[6]] ]
  def second_part
    sorted = (packets + DIVIDER_PACKETS).sort { |*pair| compare(*pair) ? -1 : 1 }
    DIVIDER_PACKETS.map { |packet| sorted.index(packet) + 1 }.reduce(&:*)
  end

  private

  def compare(packet_1, packet_2)
    value_1, *remainder_1 = packet_1
    value_2, *remainder_2 = packet_2

    case [value_1, value_2]
    # both nums
    in [Numeric, Numeric]
      return true if value_1 < value_2
      return false if value_1 > value_2
      return compare(remainder_1, remainder_2)

    # both lists
    in [Array, Array]
      is_valid = compare(value_1, value_2)
      return compare(remainder_1, remainder_2) if is_valid.nil?
      return is_valid

    # 1 is num, 1 is list
    in [Numeric, Array]
      compare([Array(value_1), *remainder_1], packet_2)
    in [Array, Numeric]
      compare(packet_1, [Array(value_2), *remainder_2])

    # End of packet checks
    in [nil, nil]
      return nil
    in [nil, _]
      return true
    in [_, nil]
      return false

    else
      raise "Strange packet state uncovered"
    end
  end

  def convert_data(data)
    data.split("\n\n").map do |packet_pair|
      packet_pair.split("\n").map do |packet|
        raise "Dangerous packet" unless packet.match? /^[\d,\[\] ]+$/
        eval(packet)
      end
    end
  end
  alias_method :packet_pairs, :input

  def packets
    packet_pairs.flatten(1)
  end
end

Day13.solve if __FILE__ == $0
