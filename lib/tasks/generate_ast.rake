# frozen_string_literal: true

require_relative "stmt_expr_defs"

# rubocop:disable Lint/UselessAssignment
all_defs = [
  StmtExprDef.new("Expr", "Binary", "left_expression, operator_token, right_expression"),
  StmtExprDef.new("Expr", "Grouping", "expression"),
  StmtExprDef.new("Expr", "Literal", "literal_value"),
  StmtExprDef.new("Expr", "Unary", "operator_token, right_expression"),
  StmtExprDef.new("Stmt", "Expression", "expression"),
  StmtExprDef.new("Expr", "Variable", "name"),

  # The author makes print a statement, not a function, to make it easier to do stuff.
  # I'd rather put it in as a library, but I'm leaving this here in case we want it
  # StmtExprDef.new("Stmt", "Print", "expression"),

  StmtExprDef.new("Stmt", "Var", "name, initializer_expression")
].freeze

gen_file_header = <<~FILE_HEADER
  # frozen_string_literal: true

  ## THIS IS AN AUTOGENERATED FILE--DO NOT EDIT
  module Rlox
FILE_HEADER
# rubocop:enable Lint/UselessAssignment

def write(out_file, base_class)
  out_file.puts gen_file_header
  relevant_defs = all_defs.select { |d| d.base_class == base_class }
  out_file.puts relevant_defs.first.base_class_str
  relevant_defs.each { |gen| out_file.puts gen.to_s }
  out_file.puts "end"
end

namespace :gen do
  desc "Generates Expr class definitions"
  task :expr do
    File.open("lib/rlox/expression.rb", "w") { |f| write(f, "Expr") }
  end

  desc "Generates Stmt class definitions"
  task :stmt do
    File.open("lib/rlox/statement.rb", "w") { |f| write(f, "Stmt") }
  end
end
