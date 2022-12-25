require_relative 'common'

class Day10 < AdventDay
  EXPECTED_RESULTS = { 1 => 13140, 2 => <<~OUTPUT.strip }
  ##..##..##..##..##..##..##..##..##..##..
  ###...###...###...###...###...###...###.
  ####....####....####....####....####....
  #####.....#####.....#####.....#####.....
  ######......######......######......####
  #######.......#######.......#######.....
  OUTPUT

  class CPU
    SCREEN_WIDTH = 40
    SIGNAL_TICKS = (0...6).map { |n| 20 + SCREEN_WIDTH * n }

    attr_reader :signals, :output

    def initialize
      @registers = { X: 1 }
      @clock = 0
      @signals = SIGNAL_TICKS.map { |tick| [tick, nil] }.to_h
      @output = ""
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
      draw_pixel!
      @clock += 1
      @signals[@clock] = @clock * @registers[:X] if @signals.key?(@clock)
      yield if block_given?
    end

    SCREEN = { on: '#', off: '.' }
    def draw_pixel!
      sprite_pos = @registers[:X]
      sprite_coords = [-1, 0, 1].map { |d| sprite_pos + d }
      @output << (sprite_coords.include?(@clock % SCREEN_WIDTH) ? SCREEN[:on] : SCREEN[:off])
    end

    def render
      @output.chars.each_slice(SCREEN_WIDTH).map(&:join)
    end
  end

  def first_part
    cpu = CPU.new
    cpu.run(instructions)
    cpu.signals.values.sum
  end

  def second_part
    cpu = CPU.new
    cpu.run(instructions)
    cpu.render.tap { |screen| display screen }.join("\n")
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

Day10.solve if __FILE__ == $0
