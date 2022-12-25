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
    solved_all_days = (1..24).all? { |day| [1,2].all? { |part| got_star?(day, part) } }
    solved_today = got_star?(25, 1)

    if solved_all_days && solved_today
      '🌟'
    else
      '❌'
    end
  end

  private

  def got_star?(day, part)
    formatted_day = day.to_s.rjust(2, '0')
    require_relative "./day-#{formatted_day}.rb" unless Object.const_defined?("Day#{day}")

    solver = Object.const_get("Day#{day}")
    # Ideally we'd've liked to run in the same mode as this file is actually run.
    # But we don't store the actual inputs in the repo and even less so the actual
    # answers, so we have to run these as debug instead, even if it doesn't
    # _guarantee_ that the exercises have been solved.
    solver.new.tap(&:debug!).run(part) == solver::EXPECTED_RESULTS[part]
  end

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

Day25.solve if __FILE__ == $0
