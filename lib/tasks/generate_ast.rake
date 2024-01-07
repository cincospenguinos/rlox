# frozen_string_literal: true

require "ostruct"

## StmtExprVars
#
# Abstraction of instance variables in statement and expression classes
class StmtExprVars
  attr_reader :instance_vars

  def initialize(instance_vars)
    @instance_vars = instance_vars.split(",").map(&:strip)
  end

  def list
    instance_vars.join(", ")
  end

  def attr_string
    str = instance_vars
          .map { |i| ":#{i}" }
          .join(", ")

    "attr_reader #{str}"
  end

  def assignment_string
    instance_vars
      .map { |i| "    @#{i} = #{i}" }
      .join("\n")
  end
end

EXPRESSION_DEFS = [
  "Binary   : left_expression, operator_token, right_expression",
  "Grouping : expression",
  "Literal  : literal_value",
  "Unary    : operator_token, right_expression"
].freeze

StmtExprDef = Struct.new(:base_class, :class_name, :instance_vars) do
  def vars
    @vars ||= StmtExprVars.new(instance_vars)
  end

  def to_s
    <<~EXPRESSION_CLASS_STR
      class #{class_name}#{base_class} < #{base_class}
        #{vars.attr_string}

        def initialize(#{vars.list})
          #{vars.assignment_string}
        end

        def accept(visitor)
          visitor.visit_#{class_name.downcase}_expr(self)
        end
      end
    EXPRESSION_CLASS_STR
  end

  def base_class_str
    <<~BASE_CLASS_STR
      class #{base_class}
      end
    BASE_CLASS_STR
  end

  def self.file_header
    <<~FILE_HEADER
      # frozen_string_literal: true

      ## THIS IS AN AUTOGENERATED FILE--DO NOT EDIT
      module Rlox

    FILE_HEADER
  end
end

ALL_DEFS = [
  StmtExprDef.new("Expr", "Binary", "left_expression, operator_token, right_expression"),
  StmtExprDef.new("Expr", "Grouping", "expression"),
  StmtExprDef.new("Expr", "Literal", "literal_value"),
  StmtExprDef.new("Expr", "Unary", "operator_token, right_expression"),
].freeze

## StmtExprClassGeneration
#
# Creates string of class to print into file, extending base Expression class
class StmtExprClassGeneration
  attr_reader :instance_vars
  attr_accessor :base_class_name, :class_name

  def initialize(base_class_name)
    @base_class_name = base_class_name
  end

  def instance_vars=(instance_vars)
    @instance_vars = StmtExprVars.new(instance_vars)
  end

  def to_s
    <<~EXPRESSION_CLASS_STR
      class #{class_name}#{base_class_name} < #{base_class_name}
        #{instance_vars.attr_string}

        def initialize(#{instance_vars.list})
          #{instance_vars.assignment_string}
        end

        def accept(visitor)
          visitor.visit_#{class_name.downcase}_expr(self)
        end
      end
    EXPRESSION_CLASS_STR
  end

  def base_class_str
    <<~BASE_CLASS_STR
      class #{base_class_name}
      end
    BASE_CLASS_STR
  end

  def self.file_header
    <<~FILE_HEADER
      # frozen_string_literal: true

      ## THIS IS AN AUTOGENERATED FILE--DO NOT EDIT
      module Rlox

    FILE_HEADER
  end
end

namespace :gen do
  GEN_FILE_HEADER = <<~FILE_HEADER
    # frozen_string_literal: true

    ## THIS IS AN AUTOGENERATED FILE--DO NOT EDIT
    module Rlox
  FILE_HEADER

  def write(out_file, base_class)
    out_file.puts GEN_FILE_HEADER
    relevant_defs = ALL_DEFS.select { |d| d.base_class == "Expr" }
    out_file.puts relevant_defs.first.base_class_str
    relevant_defs.each { |gen| out_file.puts gen.to_s }
    out_file.puts "end"
  end

  desc "Generates Expr class definitions"
  task :expr do
    File.open("lib/rlox/expression.rb", "w") { |f| write(f, "Expr") }
  end
end
