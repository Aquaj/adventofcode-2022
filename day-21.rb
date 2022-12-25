require_relative 'common'
require 'rltk'
require 'z3'

class Day21 < AdventDay
  EXPECTED_RESULTS = { 1 => 152, 2 => 301 }

  class MonkeyLexer < RLTK::Lexer
    rule(/\+/) { [:PLS, -> (a,b) { a + b  }] }
    rule(/-/)  { [:SUB, -> (a,b) { a - b  }] }
    rule(/\*/) { [:MUL, -> (a,b) { a * b  }] }
    rule(/\//) { [:DIV, -> (a,b) { a / b  }] }
    rule(/=/)  { [:EQL, -> (a,b) { a == b }] }

    rule(/[0-9]+/) { |t| [:NUM, t.to_i] }

    rule(/\n/) { :NEWLINE }

    rule(/\s/)
    rule(/\w+/) { |t| [:NAME, t] }
    rule(/:/) { |t| :ASSIGN }
  end

  require 'rltk/ast'
  module Nodes
    class Expression < RLTK::ASTNode
    end

    class Integer < Expression
      value :value, ::Integer

      def resolve(_)
        value
      end
    end

    class Variable < Expression
      value :name, String

      def resolve(context)
        context[name].call
      end
    end

    class Operation < Expression
      value :op, Proc
      child :e0, Expression
      child :e1, Expression

      def resolve(context)
        op.call e0.resolve(context), e1.resolve(context)
      end
    end

    class Assignment < RLTK::ASTNode
      child :variable, Variable
      child :value, Expression

      def resolve(context)
        context[variable.name] = -> { value.resolve(context) }
      end
    end
  end

  class MonkeyParser < RLTK::Parser
    include Nodes

    left  :PLS, :SUB
    right :MUL, :DIV

    nonempty_list(:instructions, 'assignment', 'NEWLINE')

    production(:assignment) do
      clause('.variable ASSIGN .expression') { |var, val| Assignment.new(var, val) }
    end

    production(:expression) do
      clause('variable') { |e| e }
      clause('int') { |e| e }
      clause('expression PLS expression') { |e0, op, e1| Operation.new(op, e0, e1) }
      clause('expression SUB expression') { |e0, op, e1| Operation.new(op, e0, e1) }
      clause('expression MUL expression') { |e0, op, e1| Operation.new(op, e0, e1) }
      clause('expression DIV expression') { |e0, op, e1| Operation.new(op, e0, e1) }
      clause('expression EQL expression') { |e0, op, e1| Operation.new(op, e0, e1) }
    end

    production(:variable) do
      clause('NAME') { |n| Variable.new(n) }
    end

    production(:int) do
      clause('NUM') { |n| Integer.new(n.to_i) }
    end

    finalize
  end

  def first_part
    tokens = MonkeyLexer.lex(instructions)
    ast = MonkeyParser.parse(tokens)
    runtime = ast.each_with_object({}) do |instruction, context|
      instruction.resolve(context)
    end

    runtime['root'].call
  end

  def second_part
    new_instructions = instructions.gsub(/root: (\w*) . (\w*)/, 'root: \1 = \2')

    tokens = MonkeyLexer.lex(new_instructions)
    ast = MonkeyParser.parse(tokens)
    runtime = ast.each_with_object({}) do |instruction, context|
      instruction.resolve(context)
    end

    solver = Z3::Solver.new
    answer = Z3::Int('?')

    # Modifying runtime before we run `root` to 'record'
    # all that will need to happen to make the numbers match
    runtime['humn'] = -> { answer }
    equality = runtime['root'].call

    solver.assert equality
    solver.model[answer].to_i if solver.satisfiable?
  end

  private

  def convert_data(data)
    data.strip
  end
  alias_method :instructions, :input
end

Day21.solve if __FILE__ == $0
