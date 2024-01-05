module Rlox
  class Parser
    PRIMARY_EXPR_TYPES = %i(number_literal string_literal true false nil)

    attr_reader :tokens

    def initialize(tokens)
      @tokens = tokens.freeze
      @current_index = 0
    end

    def next_expression
      factor_rule
    end

    private

    def factor_rule
      # byebug
      left_expr = unary_rule

      while current_matches?(:star, :slash) do
        advance
        operator = previous_token
        right_expr = unary_rule
        return BinaryExpr.new(left_expr, operator, right_expr)
      end

      left_expr
    end

    def unary_rule
      if current_matches?(:dash, :bang)
        advance
        operator = previous_token
        right_expression = unary_rule
        return UnaryExpr.new(operator, right_expression)
      end

      primary_rule
    end

    def primary_rule
      advance
      LiteralExpr.new(previous_token)
    end

    def current_token
      tokens[@current_index]
    end

    def previous_token
      tokens[@current_index - 1]
    end

    def at_end?
      @current_index >= tokens.size
    end

    def advance
      @current_index += 1
    end

    def current_matches?(*token_types)
      return false if at_end?

      token_types.any? { |type| current_token.type == type }
    end
  end
end
