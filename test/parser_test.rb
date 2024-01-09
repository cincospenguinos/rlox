# frozen_string_literal: true

require "test_helper"

# Our grammar is expanding to include this now
# program        → declaration* EOF ;
#
# declaration    → varDecl
#                | statement ;
#
# statement      → exprStmt
#                | printStmt ;
# varDecl        → "var" IDENTIFIER ( "=" expression )? ";" ;
# primary        → "true" | "false" | "nil"
#                | NUMBER | STRING
#                | "(" expression ")"
#                | IDENTIFIER ;

class ParserTest < Test::Unit::TestCase
  test "#parse_expr! upchucks when unable to create an expression" do
    tokens = scan_source(")")
    assert tokens.size == 2

    assert_raises(Rlox::ParserError, "No valid expression can be made!") { Rlox::Parser.new(tokens).parse_expr! }
  end

  test "#parse_expr! upchucks when lacking closing parentheses" do
    tokens = scan_source("(!false == true")
    assert tokens.size == 6

    assert_raises(Rlox::ParserError, "No matching right paren found!") { Rlox::Parser.new(tokens).parse_expr! }
  end

  # TODO: Test synchronize() logic when we handle statements and the like

  test "#parse_expr! handles numeric literal" do
    tokens = scan_source("123")
    assert tokens.size == 2

    expr = Rlox::Parser.new(tokens).parse_expr!
    assert expr.is_a?(Rlox::LiteralExpr)
    assert_equal expr.literal_value, Rlox::Token.new(type: :number_literal, string: "123")
  end

  test "#parse_expr! handles string literal" do
    tokens = scan_source('"123"')
    assert tokens.size == 2

    expr = Rlox::Parser.new(tokens).parse_expr!
    assert expr.is_a?(Rlox::LiteralExpr)
    assert_equal expr.literal_value, Rlox::Token.new(type: :string_literal, string: '"123"')
  end

  test "#parse_expr! handles true" do
    tokens = scan_source("true")
    assert tokens.size == 2

    expr = Rlox::Parser.new(tokens).parse_expr!
    assert expr.is_a?(Rlox::LiteralExpr)
    assert_equal expr.literal_value, Rlox::Token.new(type: :true, string: "true")
  end

  test "#parse_expr! handles false" do
    tokens = scan_source("false")
    assert tokens.size == 2

    expr = Rlox::Parser.new(tokens).parse_expr!
    assert expr.is_a?(Rlox::LiteralExpr)
    assert_equal expr.literal_value, Rlox::Token.new(type: :false, string: "false")
  end

  test "#parse_expr! handles nil" do
    tokens = scan_source("nil")
    assert tokens.size == 2

    expr = Rlox::Parser.new(tokens).parse_expr!
    assert expr.is_a?(Rlox::LiteralExpr)
    assert_equal expr.literal_value, Rlox::Token.new(type: :nil, string: "nil")
  end

  test "#parse_expr! handles unary with negative sign" do
    tokens = scan_source("-123")
    assert tokens.size == 3

    expr = Rlox::Parser.new(tokens).parse_expr!
    assert expr.is_a?(Rlox::UnaryExpr)
    assert expr.operator_token.type == :dash
  end

  test "#parse_expr! handles unary with bang operator" do
    tokens = scan_source("!false")
    assert tokens.size == 3

    expr = Rlox::Parser.new(tokens).parse_expr!
    assert expr.is_a?(Rlox::UnaryExpr)
    assert expr.operator_token.type == :bang
  end

  test "#parse_expr! handles nested unary" do
    tokens = scan_source("!!true")
    assert tokens.size == 4

    expr = Rlox::Parser.new(tokens).parse_expr!
    assert expr.is_a?(Rlox::UnaryExpr)
    assert expr.operator_token.type == :bang
    assert expr.right_expression.is_a?(Rlox::UnaryExpr)
    assert expr.right_expression.operator_token.type == :bang
  end

  test "#parse_expr! handles multiplication" do
    tokens = scan_source("2 * 3")
    assert tokens.size == 4

    # byebug
    expr = Rlox::Parser.new(tokens).parse_expr!
    assert expr.is_a?(Rlox::BinaryExpr)
    assert expr.operator_token.type == :star
  end

  test "#parse_expr! handles division" do
    tokens = scan_source("3/33")
    assert tokens.size == 4

    expr = Rlox::Parser.new(tokens).parse_expr!
    assert expr.is_a?(Rlox::BinaryExpr)
    assert expr.operator_token.type == :slash
  end

  test "#parse_expr! handles addition" do
    tokens = scan_source("1 + 1")
    assert tokens.size == 4

    expr = Rlox::Parser.new(tokens).parse_expr!
    assert expr.is_a?(Rlox::BinaryExpr)
    assert expr.operator_token.type == :plus
  end

  test "#parse_expr! handles subtraction" do
    tokens = scan_source("1 - 1")
    assert tokens.size == 4

    expr = Rlox::Parser.new(tokens).parse_expr!
    assert expr.is_a?(Rlox::BinaryExpr)
    assert expr.operator_token.type == :dash
  end

  test "#parse_expr! handles greater than comparison" do
    tokens = scan_source("1 + 3 > 4")
    assert tokens.size == 6

    expr = Rlox::Parser.new(tokens).parse_expr!
    assert expr.is_a?(Rlox::BinaryExpr)
    assert expr.operator_token.type == :greater
  end

  test "#parse_expr! handles less than comparison" do
    tokens = scan_source("1 + 3 < 4")
    assert tokens.size == 6

    expr = Rlox::Parser.new(tokens).parse_expr!
    assert expr.is_a?(Rlox::BinaryExpr)
    assert expr.operator_token.type == :less
  end

  test "#parse_expr! handles less than or equal to comparison" do
    tokens = scan_source("1 + 3 <= 4")
    assert tokens.size == 6

    expr = Rlox::Parser.new(tokens).parse_expr!
    assert expr.is_a?(Rlox::BinaryExpr)
    assert expr.operator_token.type == :less_equal
  end

  test "#parse_expr! handles greater than or equal to comparison" do
    tokens = scan_source("1 + 3 >= 4")
    assert tokens.size == 6

    expr = Rlox::Parser.new(tokens).parse_expr!
    assert expr.is_a?(Rlox::BinaryExpr)
    assert expr.operator_token.type == :greater_equal
  end

  test "#parse_expr! handles equals" do
    tokens = scan_source("1 + 3 == 4")
    assert tokens.size == 6

    expr = Rlox::Parser.new(tokens).parse_expr!
    assert expr.is_a?(Rlox::BinaryExpr)
    assert expr.operator_token.type == :equal_equal
  end

  test "#parse_expr! handles not equals" do
    tokens = scan_source("1 + 3 != 4")
    assert tokens.size == 6

    expr = Rlox::Parser.new(tokens).parse_expr!
    assert expr.is_a?(Rlox::BinaryExpr)
    assert expr.operator_token.type == :bang_equal
  end

  test "#parse_expr! handles parentheses" do
    tokens = scan_source("(false)")
    assert tokens.size == 4

    expr = Rlox::Parser.new(tokens).parse_expr!
    assert expr.is_a?(Rlox::GroupingExpr)
    assert expr.expression.is_a?(Rlox::LiteralExpr)
  end

  test "#parse! handles statements" do
    tokens = scan_source("1 + 2;")
    assert tokens.size == 5

    statements = Rlox::Parser.new(tokens).parse!
    assert_equal 1, statements.size
    assert statements.first.is_a?(Rlox::ExpressionStmt)
    assert statements.first.expression.is_a?(Rlox::BinaryExpr)
  end

  test "#parse! handles variable declarations" do
    tokens = scan_source("var foo;")
    assert tokens.size == 4

    statements = Rlox::Parser.new(tokens).parse!
    assert_equal 1, statements.size
    assert statements.first.is_a?(Rlox::VarStmt)
    assert_equal "foo", statements.first.name.string
  end

  test "#parse! handles variable assignment" do
    tokens = scan_source("var bar = 12;")
    assert tokens.size == 6

    statements = Rlox::Parser.new(tokens).parse!
    assert_equal 1, statements.size
    assert statements.first.is_a?(Rlox::VarStmt)
    assert statements.first.initializer_expression.is_a?(Rlox::LiteralExpr)
    assert_equal "bar", statements.first.name.string
  end

  test "#parse! handles both declaration and assignment" do
    omit "We'll handle more complex stuff later"
    tokens = scan_source("var foo; foo = 12;")
    assert tokens.size == 8

    statements = Rlox::Parser.new(tokens).parse!
    assert_equal 2, statements.size
    assert statements.first.is_a?(Rlox::VarStmt)
    assert statements.last.is_a?(Rlox::VarStmt)
  end
end
