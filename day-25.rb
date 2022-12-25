require_relative 'common'

class Day25 < AdventDay
  EXPECTED_RESULTS = { 1 => "2=-1=0", 2 => '🌟' }

  SNAFU = {
    '2' => 2,
    '1' => 1,
    '0' => 0,
    '-' => -1,
    '=' => -2,
  }

  def first_part
    to_provide = snafus.sum { |snafu| from_snafu(snafu) }

    to_snafu(to_provide)
  end

  def second_part
    '🌟'
  end

  private

  def from_snafu(snafu)
    snafu.chars.reverse.each_with_index.reduce(0) do |num, (digit, rank)|
      num + 5**rank * SNAFU[digit]
    end
  end

  def to_snafu(num)
    digits = num.to_s(5).chars
    digits.reverse.each_with_index.each_with_object([]) do |(digit, rank), snafu|
      digit = digit.to_i + snafu[rank].to_i # incorporating carryover from previous digits

      carryover, digit = digit.divmod 5

      # Rotation fro 0;4 to -2;2
      new_digit = (digit + 2) % 5 - 2

      snafu[rank] = new_digit
      carryover += 1 if new_digit.negative?

      snafu[rank+1] = carryover if carryover > 0
    end.reverse.map { |digit| SNAFU.invert[digit] }.join
  end

  def convert_data(data)
    super
  end
  alias_method :snafus, :input
end

Day25.solve
