# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "rlox"

require "test-unit"
require "byebug"

def scan_source(source_string)
  Rlox::Scanner.new(source_string).scan_tokens
end

def parse_source(source_string)
  Rlox::Parser.new(scan_source(source_string))
end
