# frozen_string_literal: true

require "test_helper"

class ParserTest < Test::Unit::TestCase
  test "#parse! upchucks when unable to create an expression" do
    tokens = scan_source(")")
    assert tokens.size == 2

    assert_raises(Rlox::ParserError, "No valid expression can be made!") { Rlox::Parser.new(tokens).parse! }
  end

  test "#parse! upchucks when lacking closing parentheses" do
    tokens = scan_source("(!false == true")
    assert tokens.size == 6

    assert_raises(Rlox::ParserError, "No matching right paren found!") { Rlox::Parser.new(tokens).parse! }
  end

  # TODO: Test synchronize() logic when we handle statements and the like

  test "#parse! handles numeric literal" do
    tokens = scan_source("123")
    assert tokens.size == 2

    expr = Rlox::Parser.new(tokens).parse!
    assert expr.is_a?(Rlox::LiteralExpr)
    assert_equal expr.literal_value, Rlox::Token.new(type: :number_literal, string: "123")
  end

  test "#parse! handles string literal" do
    tokens = scan_source('"123"')
    assert tokens.size == 2

    expr = Rlox::Parser.new(tokens).parse!
    assert expr.is_a?(Rlox::LiteralExpr)
    assert_equal expr.literal_value, Rlox::Token.new(type: :string_literal, string: '"123"')
  end

  test "#parse! handles true" do
    tokens = scan_source("true")
    assert tokens.size == 2

    expr = Rlox::Parser.new(tokens).parse!
    assert expr.is_a?(Rlox::LiteralExpr)
    assert_equal expr.literal_value, Rlox::Token.new(type: :true, string: "true")
  end

  test "#parse! handles false" do
    tokens = scan_source("false")
    assert tokens.size == 2

    expr = Rlox::Parser.new(tokens).parse!
    assert expr.is_a?(Rlox::LiteralExpr)
    assert_equal expr.literal_value, Rlox::Token.new(type: :false, string: "false")
  end

  test "#parse! handles nil" do
    tokens = scan_source("nil")
    assert tokens.size == 2

    expr = Rlox::Parser.new(tokens).parse!
    assert expr.is_a?(Rlox::LiteralExpr)
    assert_equal expr.literal_value, Rlox::Token.new(type: :nil, string: "nil")
  end

  test "#parse! handles unary with negative sign" do
    tokens = scan_source("-123")
    assert tokens.size == 3

    expr = Rlox::Parser.new(tokens).parse!
    assert expr.is_a?(Rlox::UnaryExpr)
    assert expr.operator_token.type == :dash
  end

  test "#parse! handles unary with bang operator" do
    tokens = scan_source("!false")
    assert tokens.size == 3

    expr = Rlox::Parser.new(tokens).parse!
    assert expr.is_a?(Rlox::UnaryExpr)
    assert expr.operator_token.type == :bang
  end

  test "#parse! handles nested unary" do
    tokens = scan_source("!!true")
    assert tokens.size == 4

    expr = Rlox::Parser.new(tokens).parse!
    assert expr.is_a?(Rlox::UnaryExpr)
    assert expr.operator_token.type == :bang
    assert expr.right_expression.is_a?(Rlox::UnaryExpr)
    assert expr.right_expression.operator_token.type == :bang
  end

  test "#parse! handles multiplication" do
    tokens = scan_source("2 * 3")
    assert tokens.size == 4

    # byebug
    expr = Rlox::Parser.new(tokens).parse!
    assert expr.is_a?(Rlox::BinaryExpr)
    assert expr.operator_token.type == :star
  end

  test "#parse! handles division" do
    tokens = scan_source("3/33")
    assert tokens.size == 4

    expr = Rlox::Parser.new(tokens).parse!
    assert expr.is_a?(Rlox::BinaryExpr)
    assert expr.operator_token.type == :slash
  end

  test "#parse! handles addition" do
    tokens = scan_source("1 + 1")
    assert tokens.size == 4

    expr = Rlox::Parser.new(tokens).parse!
    assert expr.is_a?(Rlox::BinaryExpr)
    assert expr.operator_token.type == :plus
  end

  test "#parse! handles subtraction" do
    tokens = scan_source("1 - 1")
    assert tokens.size == 4

    expr = Rlox::Parser.new(tokens).parse!
    assert expr.is_a?(Rlox::BinaryExpr)
    assert expr.operator_token.type == :dash
  end

  test "#parse! handles greater than comparison" do
    tokens = scan_source("1 + 3 > 4")
    assert tokens.size == 6

    expr = Rlox::Parser.new(tokens).parse!
    assert expr.is_a?(Rlox::BinaryExpr)
    assert expr.operator_token.type == :greater
  end

  test "#parse! handles less than comparison" do
    tokens = scan_source("1 + 3 < 4")
    assert tokens.size == 6

    expr = Rlox::Parser.new(tokens).parse!
    assert expr.is_a?(Rlox::BinaryExpr)
    assert expr.operator_token.type == :less
  end

  test "#parse! handles less than or equal to comparison" do
    tokens = scan_source("1 + 3 <= 4")
    assert tokens.size == 6

    expr = Rlox::Parser.new(tokens).parse!
    assert expr.is_a?(Rlox::BinaryExpr)
    assert expr.operator_token.type == :less_equal
  end

  test "#parse! handles greater than or equal to comparison" do
    tokens = scan_source("1 + 3 >= 4")
    assert tokens.size == 6

    expr = Rlox::Parser.new(tokens).parse!
    assert expr.is_a?(Rlox::BinaryExpr)
    assert expr.operator_token.type == :greater_equal
  end

  test "#parse! handles equals" do
    tokens = scan_source("1 + 3 == 4")
    assert tokens.size == 6

    expr = Rlox::Parser.new(tokens).parse!
    assert expr.is_a?(Rlox::BinaryExpr)
    assert expr.operator_token.type == :equal_equal
  end

  test "#parse! handles not equals" do
    tokens = scan_source("1 + 3 != 4")
    assert tokens.size == 6

    expr = Rlox::Parser.new(tokens).parse!
    assert expr.is_a?(Rlox::BinaryExpr)
    assert expr.operator_token.type == :bang_equal
  end

  test "#parse! handles parentheses" do
    tokens = scan_source("(false)")
    assert tokens.size == 4

    expr = Rlox::Parser.new(tokens).parse!
    assert expr.is_a?(Rlox::GroupingExpr)
    assert expr.expression.is_a?(Rlox::LiteralExpr)
  end
end
