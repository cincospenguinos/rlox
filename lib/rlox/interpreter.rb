# frozen_string_literal: true
module Rlox
  class Interpreter
    def initialize
    end

    def visit_binary_expr(binary_expr)
      left = evaluate(binary_expr.left_expression)
      right = evaluate(binary_expr.right_expression)

      case binary_expr.operator_token.type
      when :plus
        left + right
      when :dash
        left - right
      when :star
        left * right
      when :slash
        left / right
      else
        raise InterpreterError, "'#{binary_expr.operator_token.to_s}' is not a valid operator!"
      end
    end

    def visit_grouping_expr(grouping_expr)
      evaluate(grouping_expr.expression)
    end

    def visit_literal_expr(literal_expr)
      token = literal_expr.literal_value
      return parse_unary_value(token.string) if %i[false true nil].include?(token.type)

      case token.type
      when :number_literal
        token.string.to_f
      when :string_literal
        "#{token.string.gsub('"', '')}"
      else
        raise InterpreterError, "'#{literal_expr.to_s}' does not match literal type!"
      end
    end

    def visit_unary_expr(unary_expr)
      right_value = evaluate(unary_expr.right_expression)
      case unary_expr.operator_token.type
      when :dash
        -right_value
      when :bang
        !right_value
      else
        raise InterpreterError, "'#{unary_expr.to_s}' does not have valid unary operator!"
      end
    end

    private

    ## parse_unary_value
    #
    # Responds with true, false, or nil, matching the string or,
    # if the string is not false or nil, returns true
    def parse_unary_value(str)
      return true if str == "true"
      return false if str == "false"
      return nil if str == "nil"

      true
    end

    def evaluate(expression)
      expression.accept(self)
    end
  end
end
