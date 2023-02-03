# frozen_string_literal: true

require "test_helper"

class AstStringifierTest < Test::Unit::TestCase
  test '#stringify handles literal binary expressions' do
    stringifier = Rlox::AstStringifier.new
    str = stringifier.stringify(
      Rlox::BinaryExpr.new(
        Rlox::LiteralExpr.new(Rlox::Token.new(type: :number_literal, string: '1')),
        Rlox::Token.new(type: :plus, string: '+'),
        Rlox::LiteralExpr.new(Rlox::Token.new(type: :number_literal, string: '2')),
      )
    )
    assert_equal '(+ 1 2)', str
  end

  test '#stringify handles more complex case' do
    stringifier = Rlox::AstStringifier.new
    str = stringifier.stringify(
      Rlox::BinaryExpr.new(
        Rlox::UnaryExpr.new(
          Rlox::Token.new(type: :minus, string: '-'),
          Rlox::LiteralExpr.new(Rlox::Token.new(type: :number_literal, string: '123')),
        ),
        Rlox::Token.new(type: :star, string: '*'),
        Rlox::GroupingExpr.new(
          Rlox::LiteralExpr.new(Rlox::Token.new(type: :number_literal, string: '45.67'))
        )
      )
    )

    assert_equal '(* (- 123) (group 45.67))', str
  end
end
