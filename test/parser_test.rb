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
end
