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
    expr = parse_source('true')
    interpreter = Rlox::Interpreter.new

    assert_equal true, interpreter.visit_literal_expr(expr)
  end

  test "#visit_literal_expr responds with false" do
    expr = parse_source('false')
    interpreter = Rlox::Interpreter.new

    assert_equal false, interpreter.visit_literal_expr(expr)
  end

  test "#visit_literal_expr responds with nil" do
    expr = parse_source('nil')
    interpreter = Rlox::Interpreter.new

    assert_equal nil, interpreter.visit_literal_expr(expr)
  end

  test "#visit_unary_expr handles negative operation" do
    expr = parse_source("-977112")
    value = Rlox::Interpreter.new.visit_unary_expr(expr)

    assert_equal -977112, value
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
end
