# frozen_string_literal: true

module Rlox
  class ExpressionRuleResolver
    PRIMARY_RULE_LITERALS = %i[number_literal string_literal true false nil].freeze

    attr_reader :parser

    def initialize(parser)
      @parser = parser
    end

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

    def unary_rule
      if parser.current_matches?(:dash, :bang)
        operator = parser.advance
        right_expression = unary_rule
        return UnaryExpr.new(operator, right_expression)
      end

      primary_rule
    end

    def primary_rule
      return LiteralExpr.new(parser.advance) if parser.current_matches?(*PRIMARY_RULE_LITERALS)

      if parser.current_matches?(:left_paren)
        parser.advance
        inner_expression = expression_rule
        parser.consume(:right_paren, "No matching right paren found!")
        return GroupingExpr.new(inner_expression)
      end

      raise ParserError, "No valid expression can be made!"
    end

    private

    ## binary_expr_rule
    #
    # Abstract representation of a binary expression rule. Accepts name of the rule
    # that the one instantiated is to defer to, and what types of tokens to match upon
    # for this instance of the rule.
    def binary_expr_rule(higher_precedence_rule, types_to_match)
      left_expr = send(higher_precedence_rule)

      if parser.current_matches?(*types_to_match)
        operator = parser.advance
        right_expr = send(higher_precedence_rule)
        return BinaryExpr.new(left_expr, operator, right_expr)
      end

      left_expr
    end
  end

  class Parser
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
      statements = []

      until at_end? do
        statements << declaration_rule
      end

      statements
    end

    ## parse_expr!
    #
    # Parses from an expression level, not a statement level
    def parse_expr!
      ExpressionRuleResolver.new(self).expression_rule
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

    # TODO: Do we want #consume to be public? Or do we want a separate
    # tokens object that keeps track of all that information, and pass
    # a reference to that along to any resolution classes as part of this
    # restructuring thing?
    def consume(token_type, error_message)
      if current_matches?(token_type)
        advance
        return current_token
      end

      raise ParserError, error_message
    end

    private

    def declaration_rule
      return var_declaration_rule if current_matches?(:var)

      statement_expr_rule
    end

    def var_declaration_rule
      advance
      var_name = advance
      initializer_expression = nil
      if current_matches?(:equal)
        advance
        initializer_expression = ExpressionRuleResolver.new(self).expression_rule
      end

      consume(:semicolon, "Expect ';' after variable declaration")
      VarStmt.new(var_name, initializer_expression)
    end

    def statement_expr_rule
      expr = ExpressionRuleResolver.new(self).expression_rule
      consume(:semicolon, "Expect ';' after value.")
      ExpressionStmt.new(expr)
    end
  end
end
