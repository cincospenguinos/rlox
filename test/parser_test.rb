# frozen_string_literal: true

require "test_helper"

# So the order of precedence needs to be
# equality
# comparison
# addition
# multiplication
# unary
#
# Here's the grammar we're doing now:
# expression     → equality ;
# equality       → comparison ( ( "!=" | "==" ) comparison )* ;
# comparison     → term ( ( ">" | ">=" | "<" | "<=" ) term )* ;
# term           → factor ( ( "-" | "+" ) factor )* ;
# factor         → unary ( ( "/" | "*" ) unary )* ;
# unary          → ( "!" | "-" ) unary
#                | primary ;
# primary        → NUMBER | STRING | "true" | "false" | "nil"
#                | "(" expression ")" ;

class ParserTest < Test::Unit::TestCase
  test '#next_expression handles numeric literal' do
    tokens = Rlox::Scanner.new('123').scan_tokens
    assert tokens.size == 1

    expr = Rlox::Parser.new(tokens).next_expression
    assert expr.is_a?(Rlox::LiteralExpr)
    assert_equal expr.literal_value, Rlox::Token.new(type: :number_literal, string: '123')
  end

  test '#next_expression handles string literal' do
    tokens = Rlox::Scanner.new('"123"').scan_tokens
    assert tokens.size == 1

    expr = Rlox::Parser.new(tokens).next_expression
    assert expr.is_a?(Rlox::LiteralExpr)
    assert_equal expr.literal_value, Rlox::Token.new(type: :string_literal, string: '"123"')
  end

  test '#next_expression handles true' do
    tokens = Rlox::Scanner.new('true').scan_tokens
    assert tokens.size == 1

    expr = Rlox::Parser.new(tokens).next_expression
    assert expr.is_a?(Rlox::LiteralExpr)
    assert_equal expr.literal_value, Rlox::Token.new(type: :true, string: 'true')
  end

  test '#next_expression handles false' do
    tokens = Rlox::Scanner.new('false').scan_tokens
    assert tokens.size == 1

    expr = Rlox::Parser.new(tokens).next_expression
    assert expr.is_a?(Rlox::LiteralExpr)
    assert_equal expr.literal_value, Rlox::Token.new(type: :false, string: 'false')
  end

  test '#next_expression handles nil' do
    tokens = Rlox::Scanner.new('nil').scan_tokens
    assert tokens.size == 1

    expr = Rlox::Parser.new(tokens).next_expression
    assert expr.is_a?(Rlox::LiteralExpr)
    assert_equal expr.literal_value, Rlox::Token.new(type: :nil, string: 'nil')
  end

  # TODO: Test upchucking on non-literal token

  test '#next_expression handles unary with negative sign' do
    tokens = Rlox::Scanner.new('-123').scan_tokens
    assert tokens.size == 2

    expr = Rlox::Parser.new(tokens).next_expression
    assert expr.is_a?(Rlox::UnaryExpr)
    assert expr.operator_token.type == :dash
  end

  test '#next_expression handles unary with bang operator' do
    tokens = Rlox::Scanner.new('!false').scan_tokens
    assert tokens.size == 2

    expr = Rlox::Parser.new(tokens).next_expression
    assert expr.is_a?(Rlox::UnaryExpr)
    assert expr.operator_token.type == :bang
  end

  test '#next_expression handles nested unary' do
    tokens = Rlox::Scanner.new('!!true').scan_tokens
    assert tokens.size == 3

    expr = Rlox::Parser.new(tokens).next_expression
    assert expr.is_a?(Rlox::UnaryExpr)
    assert expr.operator_token.type == :bang
    assert expr.right_expression.is_a?(Rlox::UnaryExpr)
    assert expr.right_expression.operator_token.type == :bang
  end

  test '#next_expression handles multiplication' do
    tokens = Rlox::Scanner.new('2 * 3').scan_tokens
    assert tokens.size == 3

    expr = Rlox::Parser.new(tokens).next_expression
    assert expr.is_a?(Rlox::BinaryExpr)
    assert expr.operator_token.type == :star
  end
end
