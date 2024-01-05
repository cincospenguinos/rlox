module Rlox
  class Parser
    PRIMARY_EXPR_TYPES = %i(number_literal string_literal true false nil)
    attr_reader :tokens

    def initialize(tokens)
      @tokens = tokens.freeze
      @current_index = 0
    end

    def next_expression
      return literal_expr if current_matches?(*PRIMARY_EXPR_TYPES)

      nil
    end

    private

    def literal_expr
      LiteralExpr.new(current_token)
    end

    def current_token
      @tokens[@current_index]
    end

    def current_matches?(*token_types)
      token_types.any? { |type| current_token.type == type }
    end
  end
end
