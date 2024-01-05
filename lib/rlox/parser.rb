# frozen_string_literal: true

module Rlox
  class Parser
    PRIMARY_RULE_LITERALS = %i[number_literal string_literal true false nil].freeze

    attr_reader :tokens

    def initialize(tokens)
      @tokens = tokens.freeze
      @current_index = 0
    end

    def parse
      parse!
    rescue ParserError
      nil
    end

    def parse!
      expression_rule
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
      previous_token
    end

    def current_matches?(*token_types)
      return false if at_end?

      token_types.any? { |type| current_token.type == type }
    end

    private

    def expression_rule
      equality_rule
    end

    def equality_rule
      binary_expr_rule(:comparison_rule, %i[equal_equal bang_equal].freeze)
    end

    def comparison_rule
      binary_expr_rule(:term_rule, %i[greater less less_equal greater_equal].freeze)
    end

    def term_rule
      binary_expr_rule(:factor_rule, %i[plus dash].freeze)
    end

    def factor_rule
      binary_expr_rule(:unary_rule, %i[star slash].freeze)
    end

    ## binary_expr_rule
    #
    # Abstract representation of a binary expression rule. Accepts name of the rule
    # that the one instantiated is to defer to, and what types of tokens to match upon
    # for this instance of the rule.
    def binary_expr_rule(higher_precedence_rule, types_to_match)
      left_expr = send(higher_precedence_rule)

      if current_matches?(*types_to_match)
        operator = advance
        right_expr = send(higher_precedence_rule)
        return BinaryExpr.new(left_expr, operator, right_expr)
      end

      left_expr
    end

    def unary_rule
      if current_matches?(:dash, :bang)
        operator = advance
        right_expression = unary_rule
        return UnaryExpr.new(operator, right_expression)
      end

      primary_rule
    end

    def primary_rule
      return LiteralExpr.new(advance) if current_matches?(*PRIMARY_RULE_LITERALS)

      if current_matches?(:left_paren)
        advance
        inner_expression = expression_rule
        consume(:right_paren, "No matching right paren found!")
        return GroupingExpr.new(inner_expression)
      end

      raise ParserError, "No valid expression can be made!"
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
