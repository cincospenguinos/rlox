# frozen_string_literal: true

require_relative "rlox/version"
require_relative "rlox/lox"
require_relative "rlox/scanner"
require_relative "rlox/expression"
require_relative "rlox/ast_stringifier"
require_relative "rlox/parser"
require_relative "rlox/interpreter"

module Rlox
  class RloxError < StandardError
    attr_reader :message

    def initialize(message)
      super
      @message = message
    end

    def to_s
      @message
    end
  end

  class ScanError < RloxError; end

  class ParserError < RloxError; end
end
