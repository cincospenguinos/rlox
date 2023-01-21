# frozen_string_literal: true

require "test_helper"

class ScannerTest < Test::Unit::TestCase
  test "tokenizes single characters" do
    single_chars = "(){},.-+;*"
    expected_types = %i[left_paren right_paren left_brace right_brace comma
                        dot dash plus semicolon star]
    tokens = Rlox::Scanner.new(single_chars).scan_tokens
    assert_equal single_chars.chars, tokens.map(&:string)
    assert_equal expected_types, tokens.map(&:type)
  end

  test "tokenizes multi-character operators" do
    operators = %w[! != == = < <= > >=]
    expected_types = %i[bang bang_equal equal_equal equal less
                        less_equal greater greater_equal]
    tokens = Rlox::Scanner.new(operators.join).scan_tokens
    assert_equal operators, tokens.map(&:string)
    assert_equal expected_types, tokens.map(&:type)
  end

  test "tokenizes comments properly" do
    tokens = Rlox::Scanner.new("// this is a comment").scan_tokens
    assert_equal :comment, tokens.first.type
  end

  test "tokenizes the slash operator" do
    tokens = Rlox::Scanner.new("/").scan_tokens
    assert_equal :slash, tokens.first.type
  end

  test "tokenizes strings" do
    tokens = Rlox::Scanner.new('"this is a string"').scan_tokens
    assert_equal 1, tokens.size
    assert_equal :string_literal, tokens.first.type
    assert_equal '"this is a string"', tokens.first.string
  end

  test "scanner ignores whitespace" do
    str = "  +
      \r
    "
    tokens = Rlox::Scanner.new(str).scan_tokens
    assert_equal 1, tokens.size
    refute_equal :invalid_token, tokens.first.type
    assert_equal "+", tokens.first.string
  end

  test "tokenizes invalid characters as invalid" do
    invalid_chars = '#@^'
    tokens = Rlox::Scanner.new(invalid_chars).scan_tokens
    assert(tokens.map(&:type).all? { |t| t == :invalid_token })
  end

  test "tokenizes string literals" do
    tokens = Rlox::Scanner.new('"string literal"').scan_tokens
    assert_equal 1, tokens.size
    assert_equal :string_literal, tokens[0].type
  end

  test "tokenizer accepts numeric literals" do
    tokens = Rlox::Scanner.new('1 92 12.3 0.11022').scan_tokens
    assert_equal 4, tokens.size
    assert(tokens.map(&:type).all? { |t| t == :number_literal })
  end

  test "scanner emits errors for invalid chars" do
    invalid_chars = '#@^'
    scanner = Rlox::Scanner.new(invalid_chars)
    scanner.scan_tokens
    assert scanner.errors.any?
    assert scanner.errors.first.to_s.include?("invalid token")
  end

  test "scanner emits errors for unclosed string" do
    scanner = Rlox::Scanner.new('"this is a string')
    scanner.scan_tokens
    assert scanner.errors.any?
    assert scanner.errors.first.to_s.include?("unclosed string")
  end

  test "scanner handles invalid number error" do
    scanner = Rlox::Scanner.new("12. ")
    scanner.scan_tokens
    assert scanner.errors.any?
    assert scanner.errors.first.to_s.include?("unbounded decimal")
  end
end
