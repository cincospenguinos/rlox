# frozen_string_literal: true

require "test_helper"

class RloxTest < Test::Unit::TestCase
  test "VERSION" do
    assert do
      ::Rlox.const_defined?(:VERSION)
    end
  end
end
