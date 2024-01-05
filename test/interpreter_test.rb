# frozen_string_literal: true

require "test_helper"

class InterpreterTest < Test::Unit::TestCase
  test "#visit_literal_expr responds with numeric literal" do
    expr = parse_source("123")
    interpreter = Rlox::Interpreter.new

    assert_equal 123, interpreter.visit_literal_expr(expr)
  end

  test "#visit_literal_expr responds with floating point literal" do
    expr = parse_source("123.4")
    interpreter = Rlox::Interpreter.new

    assert_equal 123.4, interpreter.visit_literal_expr(expr)
  end

  test "#visit_literal_expr responds with string literal" do
    expr = parse_source('"1234"')
    interpreter = Rlox::Interpreter.new

    assert_equal "1234", interpreter.visit_literal_expr(expr)
  end

  test "#visit_literal_expr responds with true" do
    expr = parse_source("true")
    interpreter = Rlox::Interpreter.new

    assert_equal true, interpreter.visit_literal_expr(expr)
  end

  test "#visit_literal_expr responds with false" do
    expr = parse_source("false")
    interpreter = Rlox::Interpreter.new

    assert_equal false, interpreter.visit_literal_expr(expr)
  end

  test "#visit_literal_expr responds with nil" do
    expr = parse_source("nil")
    interpreter = Rlox::Interpreter.new

    assert_equal nil, interpreter.visit_literal_expr(expr)
  end

  test "#visit_unary_expr handles negative operation" do
    expr = parse_source("-977112")
    value = Rlox::Interpreter.new.visit_unary_expr(expr)

    assert_equal(-977_112, value)
  end

  test "#visit_unary_expr handles not bool" do
    value = Rlox::Interpreter.new.visit_unary_expr(parse_source("!false"))
    assert_equal true, value

    value = Rlox::Interpreter.new.visit_unary_expr(parse_source("!true"))
    assert_equal false, value
  end

  test "#visit_unary_expr handles nested bool" do
    value = Rlox::Interpreter.new.visit_unary_expr(parse_source("!!!false"))
    assert_equal true, value
  end

  test "#visit_unary_expr handles bang literals" do
    value = Rlox::Interpreter.new.visit_unary_expr(parse_source("!!12"))
    assert_equal true, value
  end

  test "#visit_grouping_expr handles arbitrary grouping" do
    value = Rlox::Interpreter.new.visit_grouping_expr(parse_source("(!!(!true))"))
    assert_equal false, value
  end

  test "#visit_binary_expr handles addition" do
    value = Rlox::Interpreter.new.visit_binary_expr(parse_source("1 + 2"))
    assert_equal 3, value
  end

  test "#visit_binary_expr handles string concatenation" do
    value = Rlox::Interpreter.new.visit_binary_expr(parse_source('"1" + "2"'))
    assert_equal "12", value
  end

  test "#visit_binary_expr handles subtraction" do
    value = Rlox::Interpreter.new.visit_binary_expr(parse_source("1 - 2"))
    assert_equal(-1, value)
  end

  test "#visit_binary_expr handles multiplication" do
    value = Rlox::Interpreter.new.visit_binary_expr(parse_source("1 * 2"))
    assert_equal 2, value
  end

  test "#visit_binary_expr handles division" do
    value = Rlox::Interpreter.new.visit_binary_expr(parse_source("1 / 2"))
    assert_equal 0.5, value
  end

  test "#visit_binary_expr handles greater than" do
    value = Rlox::Interpreter.new.visit_binary_expr(parse_source("1 > 2"))
    assert_equal false, value
  end

  test "#visit_binary_expr handles greater than or equal" do
    value = Rlox::Interpreter.new.visit_binary_expr(parse_source("1 >= 1"))
    assert_equal true, value
  end

  test "#visit_binary_expr handles less than" do
    value = Rlox::Interpreter.new.visit_binary_expr(parse_source("1 < 2"))
    assert_equal true, value
  end

  test "#visit_binary_expr handles less than or equal" do
    value = Rlox::Interpreter.new.visit_binary_expr(parse_source("1 <= 0"))
    assert_equal false, value
  end

  test "#visit_binary_expr handles equality" do
    value = Rlox::Interpreter.new.visit_binary_expr(parse_source("1 == 0"))
    assert_equal false, value
  end

  test "#visit_binary_expr handles not equality" do
    value = Rlox::Interpreter.new.visit_binary_expr(parse_source("1 == 0"))
    assert_equal false, value
  end
end
