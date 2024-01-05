module Rlox
  class Parser
    PRIMARY_EXPR_TYPES = %i(number_literal string_literal true false nil)
    attr_reader :tokens

    def initialize(tokens)
      @tokens = tokens.freeze
      @current_index = 0
    end

    def next_expression
      unary_rule
    end

    private

    def unary_rule
      if current_matches?(:dash, :bang)
        operator = current_token
        @current_index += 1
        right_expression = unary_rule
        return UnaryExpr.new(operator, right_expression)
      end

      primary_rule
    end

    def primary_rule
      LiteralExpr.new(previous_token)
    end

    def current_token
      @tokens[@current_index]
    end

    def previous_token
      @tokens[@current_index - 1]
    end

    def current_matches?(*token_types)
      token_types.any? { |type| current_token.type == type }
    end
  end
end
