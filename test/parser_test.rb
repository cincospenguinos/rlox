# frozen_string_literal: true

require "test_helper"

class ParserTest < Test::Unit::TestCase
  test "#parse upchucks when unable to create an expression" do
    tokens = Rlox::Scanner.new(")").scan_tokens
    assert tokens.size == 1

    assert_raises(Rlox::ParserError, "No valid expression can be made!") { Rlox::Parser.new(tokens).parse }
  end

  test "#parse upchucks when lacking closing parentheses" do
    tokens = Rlox::Scanner.new("(!false == true").scan_tokens
    assert tokens.size == 5

    assert_raises(Rlox::ParserError, "No matching right paren found!") { Rlox::Parser.new(tokens).parse }
  end

  test "#parse handles numeric literal" do
    tokens = Rlox::Scanner.new("123").scan_tokens
    assert tokens.size == 1

    expr = Rlox::Parser.new(tokens).parse
    assert expr.is_a?(Rlox::LiteralExpr)
    assert_equal expr.literal_value, Rlox::Token.new(type: :number_literal, string: "123")
  end

  test "#parse handles string literal" do
    tokens = Rlox::Scanner.new('"123"').scan_tokens
    assert tokens.size == 1

    expr = Rlox::Parser.new(tokens).parse
    assert expr.is_a?(Rlox::LiteralExpr)
    assert_equal expr.literal_value, Rlox::Token.new(type: :string_literal, string: '"123"')
  end

  test "#parse handles true" do
    tokens = Rlox::Scanner.new("true").scan_tokens
    assert tokens.size == 1

    expr = Rlox::Parser.new(tokens).parse
    assert expr.is_a?(Rlox::LiteralExpr)
    assert_equal expr.literal_value, Rlox::Token.new(type: :true, string: "true")
  end

  test "#parse handles false" do
    tokens = Rlox::Scanner.new("false").scan_tokens
    assert tokens.size == 1

    expr = Rlox::Parser.new(tokens).parse
    assert expr.is_a?(Rlox::LiteralExpr)
    assert_equal expr.literal_value, Rlox::Token.new(type: :false, string: "false")
  end

  test "#parse handles nil" do
    tokens = Rlox::Scanner.new("nil").scan_tokens
    assert tokens.size == 1

    expr = Rlox::Parser.new(tokens).parse
    assert expr.is_a?(Rlox::LiteralExpr)
    assert_equal expr.literal_value, Rlox::Token.new(type: :nil, string: "nil")
  end

  test "#parse handles unary with negative sign" do
    tokens = Rlox::Scanner.new("-123").scan_tokens
    assert tokens.size == 2

    expr = Rlox::Parser.new(tokens).parse
    assert expr.is_a?(Rlox::UnaryExpr)
    assert expr.operator_token.type == :dash
  end

  test "#parse handles unary with bang operator" do
    tokens = Rlox::Scanner.new("!false").scan_tokens
    assert tokens.size == 2

    expr = Rlox::Parser.new(tokens).parse
    assert expr.is_a?(Rlox::UnaryExpr)
    assert expr.operator_token.type == :bang
  end

  test "#parse handles nested unary" do
    tokens = Rlox::Scanner.new("!!true").scan_tokens
    assert tokens.size == 3

    expr = Rlox::Parser.new(tokens).parse
    assert expr.is_a?(Rlox::UnaryExpr)
    assert expr.operator_token.type == :bang
    assert expr.right_expression.is_a?(Rlox::UnaryExpr)
    assert expr.right_expression.operator_token.type == :bang
  end

  test "#parse handles multiplication" do
    tokens = Rlox::Scanner.new("2 * 3").scan_tokens
    assert tokens.size == 3

    # byebug
    expr = Rlox::Parser.new(tokens).parse
    assert expr.is_a?(Rlox::BinaryExpr)
    assert expr.operator_token.type == :star
  end

  test "#parse handles division" do
    tokens = Rlox::Scanner.new("3/33").scan_tokens
    assert tokens.size == 3

    expr = Rlox::Parser.new(tokens).parse
    assert expr.is_a?(Rlox::BinaryExpr)
    assert expr.operator_token.type == :slash
  end

  test "#parse handles addition" do
    tokens = Rlox::Scanner.new("1 + 1").scan_tokens
    assert tokens.size == 3

    expr = Rlox::Parser.new(tokens).parse
    assert expr.is_a?(Rlox::BinaryExpr)
    assert expr.operator_token.type == :plus
  end

  test "#parse handles subtraction" do
    tokens = Rlox::Scanner.new("1 - 1").scan_tokens
    assert tokens.size == 3

    expr = Rlox::Parser.new(tokens).parse
    assert expr.is_a?(Rlox::BinaryExpr)
    assert expr.operator_token.type == :dash
  end

  test "#parse handles greater than comparison" do
    tokens = Rlox::Scanner.new("1 + 3 > 4").scan_tokens
    assert tokens.size == 5

    expr = Rlox::Parser.new(tokens).parse
    assert expr.is_a?(Rlox::BinaryExpr)
    assert expr.operator_token.type == :greater
  end

  test "#parse handles less than comparison" do
    tokens = Rlox::Scanner.new("1 + 3 < 4").scan_tokens
    assert tokens.size == 5

    expr = Rlox::Parser.new(tokens).parse
    assert expr.is_a?(Rlox::BinaryExpr)
    assert expr.operator_token.type == :less
  end

  test "#parse handles less than or equal to comparison" do
    tokens = Rlox::Scanner.new("1 + 3 <= 4").scan_tokens
    assert tokens.size == 5

    expr = Rlox::Parser.new(tokens).parse
    assert expr.is_a?(Rlox::BinaryExpr)
    assert expr.operator_token.type == :less_equal
  end

  test "#parse handles greater than or equal to comparison" do
    tokens = Rlox::Scanner.new("1 + 3 >= 4").scan_tokens
    assert tokens.size == 5

    expr = Rlox::Parser.new(tokens).parse
    assert expr.is_a?(Rlox::BinaryExpr)
    assert expr.operator_token.type == :greater_equal
  end

  test "#parse handles equals" do
    tokens = Rlox::Scanner.new("1 + 3 == 4").scan_tokens
    assert tokens.size == 5

    expr = Rlox::Parser.new(tokens).parse
    assert expr.is_a?(Rlox::BinaryExpr)
    assert expr.operator_token.type == :equal_equal
  end

  test "#parse handles not equals" do
    tokens = Rlox::Scanner.new("1 + 3 != 4").scan_tokens
    assert tokens.size == 5

    expr = Rlox::Parser.new(tokens).parse
    assert expr.is_a?(Rlox::BinaryExpr)
    assert expr.operator_token.type == :bang_equal
  end

  test "#parse handles parentheses" do
    tokens = Rlox::Scanner.new("(false)").scan_tokens
    assert tokens.size == 3

    expr = Rlox::Parser.new(tokens).parse
    assert expr.is_a?(Rlox::GroupingExpr)
    assert expr.expression.is_a?(Rlox::LiteralExpr)
  end
end
