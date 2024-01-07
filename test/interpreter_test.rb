# frozen_string_literal: true

require "test_helper"

class InterpreterTest < Test::Unit::TestCase
  test "#visit_literal_expr responds with numeric literal" do
    expr = parse_source_expr("123")
    interpreter = Rlox::Interpreter.new

    assert_equal 123, interpreter.visit_literal_expr(expr)
  end

  test "#visit_literal_expr responds with floating point literal" do
    expr = parse_source_expr("123.4")
    interpreter = Rlox::Interpreter.new

    assert_equal 123.4, interpreter.visit_literal_expr(expr)
  end

  test "#visit_literal_expr responds with string literal" do
    expr = parse_source_expr('"1234"')
    interpreter = Rlox::Interpreter.new

    assert_equal "1234", interpreter.visit_literal_expr(expr)
  end

  test "#visit_literal_expr responds with true" do
    expr = parse_source_expr("true")
    interpreter = Rlox::Interpreter.new

    assert_equal true, interpreter.visit_literal_expr(expr)
  end

  test "#visit_literal_expr responds with false" do
    expr = parse_source_expr("false")
    interpreter = Rlox::Interpreter.new

    assert_equal false, interpreter.visit_literal_expr(expr)
  end

  test "#visit_literal_expr responds with nil" do
    expr = parse_source_expr("nil")
    interpreter = Rlox::Interpreter.new

    assert_equal nil, interpreter.visit_literal_expr(expr)
  end

  test "#visit_unary_expr handles negative operation" do
    expr = parse_source_expr("-977112")
    value = Rlox::Interpreter.new.visit_unary_expr(expr)

    assert_equal(-977_112, value)
  end

  test "#visit_unary_expr handles not bool" do
    value = Rlox::Interpreter.new.visit_unary_expr(parse_source_expr("!false"))
    assert_equal true, value

    value = Rlox::Interpreter.new.visit_unary_expr(parse_source_expr("!true"))
    assert_equal false, value
  end

  test "#visit_unary_expr handles nested bool" do
    value = Rlox::Interpreter.new.visit_unary_expr(parse_source_expr("!!!false"))
    assert_equal true, value
  end

  test "#visit_unary_expr handles bang literals" do
    value = Rlox::Interpreter.new.visit_unary_expr(parse_source_expr("!!12"))
    assert_equal true, value
  end

  test "#visit_grouping_expr handles arbitrary grouping" do
    value = Rlox::Interpreter.new.visit_grouping_expr(parse_source_expr("(!!(!true))"))
    assert_equal false, value
  end

  test "#visit_binary_expr handles addition" do
    value = Rlox::Interpreter.new.visit_binary_expr(parse_source_expr("1 + 2"))
    assert_equal 3, value
  end

  test "#visit_binary_expr handles string concatenation" do
    value = Rlox::Interpreter.new.visit_binary_expr(parse_source_expr('"1" + "2"'))
    assert_equal "12", value
  end

  test "#visit_binary_expr handles subtraction" do
    value = Rlox::Interpreter.new.visit_binary_expr(parse_source_expr("1 - 2"))
    assert_equal(-1, value)
  end

  test "#visit_binary_expr handles multiplication" do
    value = Rlox::Interpreter.new.visit_binary_expr(parse_source_expr("1 * 2"))
    assert_equal 2, value
  end

  test "#visit_binary_expr handles division" do
    value = Rlox::Interpreter.new.visit_binary_expr(parse_source_expr("1 / 2"))
    assert_equal 0.5, value
  end

  test "#visit_binary_expr handles greater than" do
    value = Rlox::Interpreter.new.visit_binary_expr(parse_source_expr("1 > 2"))
    assert_equal false, value
  end

  test "#visit_binary_expr handles greater than or equal" do
    value = Rlox::Interpreter.new.visit_binary_expr(parse_source_expr("1 >= 1"))
    assert_equal true, value
  end

  test "#visit_binary_expr handles less than" do
    value = Rlox::Interpreter.new.visit_binary_expr(parse_source_expr("1 < 2"))
    assert_equal true, value
  end

  test "#visit_binary_expr handles less than or equal" do
    value = Rlox::Interpreter.new.visit_binary_expr(parse_source_expr("1 <= 0"))
    assert_equal false, value
  end

  test "#visit_binary_expr handles equality" do
    value = Rlox::Interpreter.new.visit_binary_expr(parse_source_expr("1 == 0"))
    assert_equal false, value
  end

  test "#visit_binary_expr handles not equality" do
    value = Rlox::Interpreter.new.visit_binary_expr(parse_source_expr("1 == 0"))
    assert_equal false, value
  end

  test "#evaluate! will handle an arbitrary expression" do
    # NOTE! The grouping of 1 + 2 is necessary for the whole expression to be
    # recognized. Attempting to fix the parser on that front was way too much for me,
    # and so I'm leaving it as a future exercise or something
    expr = parse_source_expr("(1 + 2) - (10 + (1 * 2))")
    value = Rlox::Interpreter.new.evaluate!(expr)

    assert_equal(-9, value)
  end

  test "#evaluate! throws an execution error for a bad minus operation" do
    expr = parse_source_expr('-"twelve"')
    msg = "Cannot use '-' operator on \"twelve\"!"
    assert_raises(Rlox::InterpreterError, msg) { Rlox::Interpreter.new.evaluate!(expr) }
  end

  test "#evaluate! throws an execution error for a bad comparison operation" do
    operators = %w[> >= < <=]

    operators.each do |operator|
      expr = parse_source_expr("12 #{operator} \"twelve\"")
      msg = "Cannot use '#{operator}' operator on \"twelve\"!"
      assert_raises(Rlox::InterpreterError, msg) { Rlox::Interpreter.new.evaluate!(expr) }
    end
  end

  test "#evaluate! throws an execution error for a bad comparison operation on the left" do
    operators = %w[> >= < <=]

    operators.each do |operator|
      expr = parse_source_expr("\"twelve\" #{operator} 12")
      msg = "Cannot use '#{operator}' operator on \"twelve\"!"
      assert_raises(Rlox::InterpreterError, msg) { Rlox::Interpreter.new.evaluate!(expr) }
    end
  end

  test "#evaluate! throws an execution error for attempting to divide a string" do
    expr = parse_source_expr('12 / "twelve"')
    msg = "Cannot use '/' operator on \"twelve\"!"
    assert_raises(Rlox::InterpreterError, msg) { Rlox::Interpreter.new.evaluate!(expr) }

    expr = parse_source_expr('"twelve" / 12')
    msg = "Cannot use '/' operator on \"twelve\"!"
    assert_raises(Rlox::InterpreterError, msg) { Rlox::Interpreter.new.evaluate!(expr) }
  end

  test "#evaluate! accepts one number and one string for string concatenation" do
    expr = parse_source_expr('12 + "twelve"')
    value = Rlox::Interpreter.new.evaluate!(expr)
    assert_equal "12.0twelve", value

    expr = parse_source_expr('"twelve" + 12')
    value = Rlox::Interpreter.new.evaluate!(expr)
    assert_equal "twelve12.0", value
  end

  test "#evaluate! does not allow division by zero" do
    expr = parse_source_expr("12 / 0")
    assert_raises(Rlox::InterpreterError, "Cannot divide by zero!") { Rlox::Interpreter.new.evaluate!(expr) }
  end
end
