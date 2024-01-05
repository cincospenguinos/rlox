module Rlox
  class Parser
    attr_reader :tokens

    def initialize(tokens)
      @tokens = tokens.freeze
      @current_index = 0
    end

    def next_expression
      return LiteralExpr.new(current_token) if current_matches?(:number_literal, :string_literal)

      nil
    end

    private

    def current_token
      @tokens[@current_index]
    end

    def current_matches?(*token_types)
      token_types.any? { |type| current_token.type == type }
    end
  end
end
