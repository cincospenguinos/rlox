# frozen_string_literal: true

require_relative "parser/parser_token_position"
require_relative "parser/expression_rule_resolver"

module Rlox
  class Parser
    attr_reader :tokens

    def initialize(tokens)
      @tokens = ParserTokenPosition.new(tokens)
    end

    def parse
      parse!
    rescue ParserError
      nil
    end

    def parse!
      statements = []

      statements << declaration_rule until tokens.at_end?

      statements
    end

    ## parse_expr!
    #
    # Parses from an expression level, not a statement level
    def parse_expr!
      ExpressionRuleResolver.new(tokens).expression_rule
    end

    private

    def declaration_rule
      return var_declaration_rule if tokens.current_matches?(:var)

      statement_expr_rule
    end

    def var_declaration_rule
      tokens.advance
      var_name = tokens.advance
      initializer_expression = nil
      if tokens.current_matches?(:equal)
        tokens.advance
        initializer_expression = ExpressionRuleResolver.new(tokens).expression_rule
      end

      tokens.consume(:semicolon, "Expect ';' after variable declaration")
      VarStmt.new(var_name, initializer_expression)
    end

    def statement_expr_rule
      expr = ExpressionRuleResolver.new(tokens).expression_rule
      tokens.consume(:semicolon, "Expect ';' after value.")
      ExpressionStmt.new(expr)
    end
  end
end
