# frozen_string_literal: true

require_relative "rlox/version"
require_relative "rlox/lox"
require_relative "rlox/scanner"

module Rlox
  class Error < StandardError; end

  # LoxExecutionError
  #
  # Error for when execution goes wrong
  class LoxExecutionError < Error
    attr_reader :message

    def initialize(message)
      super
      @message = message
    end

    def to_s
      @message
    end

    def self.generate_error(line_number, message)
      LoxExecutionError.new("[ERR] on line #{line_number}: #{message}")
    end
  end
end
