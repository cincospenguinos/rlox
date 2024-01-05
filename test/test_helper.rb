# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "rlox"

require "test-unit"
require "byebug"

def scan_source(source_string)
  Rlox::Scanner.new(source_string).scan
end

def parse_source(source_string)
  Rlox::Parser.new(scan_source(source_string)).parse!
end

def print_ast(source_or_expr)
  source_or_expr = parse_source(source_or_expr) if source_or_expr.is_a?(String)

  puts Rlox::AstStringifier.new.stringify(source_or_expr)
end
