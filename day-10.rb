require_relative 'common'

class Day10 < AdventDay
  EXPECTED_RESULTS = { 1 => 13140, 2 => nil }


  class CPU
    SIGNAL_TICKS = (0...6).map { |n| 20 + 40 * n }

    attr_reader :signals

    def initialize
      @registers = { X: 1 }
      @clock = 1
      @signals = SIGNAL_TICKS.map { |tick| [tick, nil] }.to_h
    end

    def run(instructions)
      instructions.each do |instruction, arg|
        case instruction
        when 'addx'
          tick!
          tick! { @registers[:X] += arg }
        when 'noop'
          tick!
        end
      end
    end

    def tick!
      @clock += 1
      yield if block_given?
      @signals[@clock] = @clock * @registers[:X] if @signals.key?(@clock)
    end
  end

  def first_part
    cpu = CPU.new
    cpu.run(instructions)
    cpu.signals.values.sum
  end

  def second_part
  end

  private

  def convert_data(data)
    super.map do |cmd|
      instr, arg = cmd.split
      [instr, arg&.to_i]
    end
  end
  alias_method :instructions, :input
end

Day10.solve
