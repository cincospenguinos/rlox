# frozen_string_literal: true
module Rlox
  class Interpreter
    def initialize
    end

    def visit_binary_expr(binary_expr)
    end

    def visit_grouping_expr(grouping_expr)
    end

    def visit_literal_expr(literal_expr)
      token = literal_expr.literal_value
      return parse_bool_or_nil(token.string) if %i[false true nil].include?(token.type)

      case token.type
      when :number_literal
        token.string.to_f
      when :string_literal
        "#{token.string.gsub('"', '')}"
      else
        raise InterpreterError, "\"#{literal_expr.to_s}\" does not match literal type!"
      end
    end

    def visit_unary_expr(unary_expr)
    end

    private

    def parse_bool_or_nil(str)
      return true if str == "true"
      return false if str == "false"
      return nil if str == "nil"

      raise InterpreterError, "\"#{str}\" is not true, false, or nil!"
    end
  end
end
