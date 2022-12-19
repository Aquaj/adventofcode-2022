require_relative 'common'
require 'z3'

class Day19 < AdventDay
  EXPECTED_RESULTS = { 1 => 33, 2 => 3472 }

  MINUTES_TO_EXTRACT = 24

  RESOURCES = %i[ore clay obsidian geode]

  def first_part
    blueprints.map { |index, blueprint| index * max_geodes_with(blueprint, minutes_to_extract: 24) }.sum
  end

  def second_part
    blueprints.slice(1,2,3).map { |_,blueprint| max_geodes_with(blueprint, minutes_to_extract: 32) }.reduce(&:*)
  end

  private

  def max_geodes_with(blueprint, minutes_to_extract:)
    solver = Z3::Optimize.new

    problem = Array.new(minutes_to_extract + 1) do |time|
      {
        spent: RESOURCES.map { |r| [r, Z3::Int("spent[#{time}][#{r}]")] }.to_h,
        built: RESOURCES.map { |r| [r, Z3::Int("built[#{time}][#{r}]")] }.to_h,
        robots: RESOURCES.map { |r| [r, Z3::Int("robots[#{time}][#{r}]")] }.to_h,
        resources: RESOURCES.map { |r| [r, Z3::Int("resources[#{time}][#{r}]")] }.to_h,
      }
    end

    (1..minutes_to_extract).each do |time|
      resource_evolution = RESOURCES.map do |resource|
        existing_resource = problem[time - 1][:resources][resource]
        new_resource = problem[time - 1][:robots][resource]

        robot_costs = blueprint.map do |type, costs|
          problem[time][:built][type] * costs.fetch(resource, 0)
        end.reduce(&:+)

        (problem[time][:spent][resource] == robot_costs) &
          (existing_resource - problem[time][:spent][resource] >= 0) &
          (problem[time][:resources][resource] == existing_resource + new_resource - problem[time][:spent][resource])
      end

      robot_evolution = RESOURCES.map do |resource|
        existing_robots = problem[time - 1][:robots][resource]
        problem[time][:robots][resource] == existing_robots + problem[time][:built][resource]
      end

      solver.assert Z3::And(
        *problem[time][:built].map { |_,c| c >= 0 },
        *problem[time][:built].map { |_,c| c <= 1 },
        problem[time][:built].values.sum <= 1,
        *problem[time][:spent].map { |_,c| c >= 0 },
        *resource_evolution,
        *robot_evolution
      )
    end

    solver.assert Z3::And(
      *RESOURCES.map { |resource| problem[0][:resources][resource] == 0 },
      *(RESOURCES - [:ore]).map { |resource| problem[0][:robots][resource] == 0 },
      problem[0][:robots][:ore] == 1,
    )

    solver.maximize problem[-1][:resources][:geode]

    solver.model[problem[-1][:resources][:geode]].to_i if solver.satisfiable?
  end

  def convert_data(data)
    super.map do |blueprint|
      id, definitions = blueprint.match(/Blueprint (\d+): (.*)/).captures
      robots = definitions.scan /Each (?<type>\w+) robot costs (?<costs>.*?)\./
      robots = robots.map do |type, costs|
        [type.to_sym, costs.scan(/(\d+) (\w+)/).to_h.reverse.transform_keys(&:to_sym).transform_values(&:to_i)]
      end.to_h
      [id.to_i, robots]
    end.to_h
  end
  alias_method :blueprints, :input
end

Day19.solve
