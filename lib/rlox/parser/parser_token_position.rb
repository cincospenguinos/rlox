# frozen_string_literal: true

module Rlox
  class ParserTokenPosition
    attr_reader :tokens

    def initialize(tokens)
      @tokens = tokens.freeze
      @current_index = 0
    end

    def current_token
      tokens[@current_index]
    end

    def previous_token
      tokens[@current_index - 1]
    end

    def at_end?
      current_token.type == :EOF
    end

    def advance
      @current_index += 1
      previous_token
    end

    def current_matches?(*token_types)
      return false if at_end?

      token_types.any? { |type| current_token.type == type }
    end

    def consume(token_type, error_message)
      if current_matches?(token_type)
        advance
        return current_token
      end

      raise ParserError, error_message
    end
  end
end
