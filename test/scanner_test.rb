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
end
