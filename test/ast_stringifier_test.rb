# frozen_string_literal: true

require "test_helper"

class AstStringifierTest < Test::Unit::TestCase
  test '#stringify handles literal binary expressions' do
    stringifier = Rlox::AstStringifier.new
    str = stringifier.stringify(
      Rlox::BinaryExpr.new(
        Rlox::Token.new(type: :number_literal, string: '1'),
        Rlox::Token.new(type: :plus, string: '+'),
        Rlox::Token.new(type: :number_literal, string: '2'),
      )
    )
    assert_equal '(+ 1 2)', str
  end
end
