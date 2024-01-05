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
end
