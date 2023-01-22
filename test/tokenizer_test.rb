# frozen_string_literal: true

require "test_helper"

class TokenizerTest < Test::Unit::TestCase
  test 'Tokenizer#advance_index advances' do
    tokenizer = Rlox::Tokenizer.new('foo')
    assert_equal 'f', tokenizer.current_slice
    assert_equal 'fo', tokenizer.advance_index.current_slice
  end

  test 'Tokenizer#advance_past_last_peek_advances' do
    tokenizer = Rlox::Tokenizer.new('bar biz')
    assert_equal 'b', tokenizer.current_slice
    assert_equal 'bar', tokenizer.current_slice(2)
    assert_equal 'bar', tokenizer.advance_past_last_peek.current_slice
  end

  test 'Tokenizer#at_end? works' do
    tokenizer = Rlox::Tokenizer.new('bar')
    refute tokenizer.at_end?
    refute tokenizer.scan.nil?
    assert tokenizer.at_end?
  end

  test 'Tokenizer#at_end? respects peek amount' do
    tokenizer = Rlox::Tokenizer.new('bar')
    assert tokenizer.at_end?(5)
  end

  # test 'Tokenizer#scan handles tokens of length of two' do
  #   tokenizer = Rlox::Tokenizer.new('fo bo')
  #   assert_equal :identifier, tokenizer.scan.type
  #   assert_equal 'b', tokenizer.advance_index.current_slice
  # end

  # test 'Tokenizer#scan handles class else' do
  #   tokenizer = Rlox::Tokenizer.new('class else')
  #   assert_equal :class, tokenizer.scan.type
  #   assert_equal 'e', tokenizer.advance_index.current_slice
  # end
end