# frozen_string_literal: true

module Rlox
  class Interpreter
    ARITHMETIC_OPERATORS = %i[plus dash star slash].freeze
    COMPARISON_OPERATORS = %i[greater less greater_equal less_equal].freeze
    BOOL_TYPES = %i[false true nil].freeze

    # TODO: We can't have separate interpret and evaluate methods. What other
    # interface can we put together?
    def interpret!(statements)
      statements.each { |s| evaluate!(s) }
      nil
    end

    def evaluate!(expression)
      expression.accept(self)
    end

    def evaluate(expression)
      expression.accept(self)
    rescue InterpreterError
      nil
    end

    def visit_expression_stmt(stmt)
      evaluate(stmt.expression)
      nil
    end

    def visit_binary_expr(binary_expr)
      operator = binary_expr.operator_token.type
      left = evaluate(binary_expr.left_expression)
      right = evaluate(binary_expr.right_expression)
      return evaluate_arithmetic_expression(operator, left, right) if ARITHMETIC_OPERATORS.include?(operator)
      return evaluate_comparison_expression(operator, left, right) if COMPARISON_OPERATORS.include?(operator)
      return left == right if operator == :equal_equal
      return left != right if operator == :bang_equal

      raise InterpreterError, "'#{binary_expr.operator_token}' is not a valid operator!"
    end

    def visit_grouping_expr(grouping_expr)
      evaluate(grouping_expr.expression)
    end

    def visit_literal_expr(literal_expr)
      token = literal_expr.literal_value
      return parse_unary_value(token.string) if BOOL_TYPES.include?(token.type)

      case token.type
      when :number_literal
        token.string.to_f
      when :string_literal
        token.string.gsub('"', "").to_s
      else
        raise InterpreterError, "'#{literal_expr}' does not match literal type!"
      end
    end

    def visit_unary_expr(unary_expr)
      right_value = evaluate(unary_expr.right_expression)
      case unary_expr.operator_token.type
      when :dash
        raise_invalid_operation_err!("-", right_value) unless number?(right_value)
        -right_value
      when :bang
        !right_value
      else
        raise InterpreterError, "'#{unary_expr}' does not have valid unary operator!"
      end
    end

    private

    def number?(value)
      value.is_a?(Numeric)
    end

    def string?(value)
      value.is_a?(String)
    end

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

    def evaluate_arithmetic_expression(operation, left, right)
      raise_invalid_operation_err!(operation, left) unless valid_arithmetic?(operation, left)
      raise_invalid_operation_err!(operation, right) unless valid_arithmetic?(operation, right)

      return evaluate_plus(left, right) if operation == :plus
      return left - right if operation == :dash
      return left * right if operation == :star
      return evaluate_division(left, right) if operation == :slash

      raise InterpreterError, "'#{operation}' is not a valid operator!"
    end

    def evaluate_plus(left, right)
      return left.to_s + right.to_s if string?(left) || string?(right)

      left + right
    end

    def evaluate_division(left, right)
      raise InterpreterError, "Cannot divide by zero!" if right.zero?

      left / right
    end

    def valid_arithmetic?(operation, value)
      return number?(value) || string?(value) if operation == :plus

      number?(value)
    end

    def evaluate_comparison_expression(operation, left, right)
      raise_invalid_operation_err!(operation, left) unless number?(left)
      raise_invalid_operation_err!(operation, right) unless number?(right)

      return left > right if operation == :greater
      return left >= right if operation == :greater_equal
      return left < right if operation == :less
      return left <= right if operation == :less_equal

      raise InterpreterError, "'#{operation}' is not a valid operator!"
    end

    def raise_invalid_operation_err!(operation, value)
      raise InterpreterError, "Cannot use '#{operation}' operator on \"#{value}\"!"
    end
  end
end
