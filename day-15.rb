require_relative 'common'
require 'z3'

# Necessary patch to make `Z3::Tactic`s work
module Z3
  def self.Tactic(name)
    Z3::Tactic.new Z3::LowLevel.mk_tactic(name)
  end

  class Tactic
    attr_reader :_tactic
    def initialize(pointer)
      @_tactic = pointer
    end

    def solver
      Z3::Solver.from_tactic(self)
    end
  end

  class Solver
    def self.from_tactic(tactic)
      pointer = Z3::LowLevel.mk_solver_from_tactic(tactic)
      new(pointer)
    end

    def initialize(pointer = ::Z3::LowLevel.mk_solver)
      @_solver = pointer
      Z3::LowLevel.solver_inc_ref(self)
      reset_model!
    end
  end
end

class Day15 < AdventDay
  EXPECTED_RESULTS = { 1 => 26, 2 => 56000011 }

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
    # Need to use a tactic because Z3 segfaults on default behaviour on my machine
    solver = Z3::Tactic('smt').solver

    x, y = Z3::Int("x"), Z3::Int("y")

    abs = -> (v) { Z3::IfThenElse(v >= 0, v, -v) }
    not_in_distance = sensors_info.map do |(sx,sy), beacon|
      not abs.(x - sx) + abs.(y - sy) <= distance_between([sx,sy], beacon)
    end
    solver.assert Z3::And(*not_in_distance)

    solver.assert x >= coords_range.begin
    solver.assert x <= coords_range.end

    solver.assert y >= coords_range.begin
    solver.assert y <= coords_range.end

    if solver.satisfiable?
      magic_coeff = 4_000_000
      solver.model[x].to_i * magic_coeff + solver.model[y].to_i
    end
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

  def coords_range
    debug? ? 0..20 : 0..4_000_000
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

Day15.solve if __FILE__ == $0
