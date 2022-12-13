require_relative 'common'

class Day13 < AdventDay
  EXPECTED_RESULTS = { 1 => 13, 2 => 140 }

  def first_part
    packet_pairs.filter_map.with_index do |pair, index|
      index + 1 if compare(*pair.deep_copy)
    end.sum
  end

  DIVIDER_PACKETS = [ [[2]], [[6]] ]
  def second_part
    sorted = (packets + DIVIDER_PACKETS).sort { |*pair| compare(*pair.deep_copy) ? -1 : 1 }
    DIVIDER_PACKETS.map { |packet| sorted.index(packet) + 1 }.reduce(&:*)
  end

  private

  def compare(packet_1, packet_2)
    value_1 = packet_1.shift
    value_2 = packet_2.shift
    case
    when [value_1, value_2].all? { |val| val.is_a? Numeric }
      return true if value_1 < value_2
      return false if value_1 > value_2
      return compare(packet_1, packet_2)
    when [value_1, value_2].all? { |val| val.is_a? Array }
      is_valid = compare(value_1, value_2)
      return compare(packet_1, packet_2) if is_valid.nil?
      return is_valid
    when value_1.is_a?(Numeric) && value_2.is_a?(Array)
      packet_1.unshift([value_1])
      packet_2.unshift(value_2)
      compare(packet_1, packet_2)
    when value_1.is_a?(Array) && value_2.is_a?(Numeric)
      packet_1.unshift(value_1)
      packet_2.unshift([value_2])
      compare(packet_1, packet_2)
    # End of packet checks
    when [value_1, value_2] == [nil, nil]
      return nil
    when value_1.nil?
      return true
    when value_2.nil?
      return false
    else
      raise "Strange packet state uncovered"
    end
  end

  def convert_data(data)
    data.split("\n\n").map do |packet_pair|
      packet_pair.split("\n").map do |packet|
        raise "Dangerous packet" unless packet.match? /^[\d,\[\]]+$/
        eval(packet)
      end
    end
  end
  alias_method :packet_pairs, :input

  def packets
    packet_pairs.flatten(1)
  end
end

Day13.solve
