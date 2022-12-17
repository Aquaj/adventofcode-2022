class Day16 < AdventDay

  Valve = Struct.new(:name, :index, :flow_rate, :neighbors, keyword_init: true) do
    def inspect = "#{self.class.name}<#{name}: #{flow_rate} — #{neighbors.transform_keys(&:name).inspect}>"
    def to_s = inspect
    def hash = object_id
    def jammed? = flow_rate == 0

    def actions
      @actions ||= [
        (ValveOpening.new(time_cost: 1, move_to: self, opens_valve: self) unless jammed?),
        *neighbors.map do |neighbor, distance|
          Travel.new(time_cost: distance, move_to: neighbor, opens_valve: nil)
        end.sort_by(&:time_cost),
        WaitHere.new(self),
      ].compact
    end
  end

  Action = Struct.new(:time_cost, :move_to, :opens_valve, keyword_init: true)
  class Travel < Action
    def inspect = "Travel<#{move_to.name} : #{time_cost}mn>"
  end

  class ValveOpening < Action
    def inspect = "Open<#{opens_valve.name} +#{opens_valve.flow_rate}>"
  end

  class WaitHere < Action
    def initialize(here) =
      super(move_to: here, time_cost: 1, opens_valve: nil)

    def inspect = "WAIT<#{move_to.name}>"
  end

  class Actor < Struct.new(:name, :time, :path, :position, keyword_init: true)
    def inspect = "<#{name}>@#{position.name}:#{time}"

    def fingerprint
      [name, time, position].map(&:hash)
    end

    def done?
      time.zero?
    end

    def available_actions
      position.actions.map { |a| Move.new(a, self) }
    end
  end

  class Move < Struct.new(:action, :actor)
    def inspect = "#{actor.name}##{action.inspect}"

    def finish_time
      @time ||= actor.time - action.time_cost
    end

    def opened_valve
      action.opens_valve
    end

    def flow_increase
      opened_valve&.flow_rate.to_i
    end

    def to_actor
      actor.dup.tap do |new_actor|
        new_actor.path = [*actor.path, action]
        new_actor.time = finish_time
        new_actor.position = action.move_to
      end
    end

    def loops?
      return false if opened_valve
      previous_travels = actor.path.reverse.take_while { |act| act.opens_valve.nil? }
      previous_travels.map(&:move_to).include?(action.move_to)
    end
  end

  class State < Struct.new(:actors, :pressure, :remaining_valves, keyword_init: true)
    def inspect = "[#{pressure}]<#{actors.map(&:name).join(', ')}>"

    def ignore!
      @ignore = true
    end

    def ignore?
      !!@ignore
    end

    def time
      actors.map(&:time).uniq.unwrap
    end

    def fingerprint
      [actors.map(&:position), actors.map(&:time)]
    end
  end
end
