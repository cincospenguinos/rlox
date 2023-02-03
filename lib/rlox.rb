# frozen_string_literal: true

require_relative "rlox/version"
require_relative "rlox/lox"
require_relative "rlox/scanner"
require_relative "rlox/expression"
require_relative "rlox/ast_stringifier"

module Rlox
  class Error < StandardError; end

  # ScanError
  #
  # Error to apper when scanning
  class ScanError < StandardError
    attr_reader :message

    def initialize(message)
      super
      @message = message
    end

    def to_s
      @message
    end
  end
end
