# frozen_string_literal: true
module Rlox
  class Interpreter
    def initialize
    end

    def visit_binary_expr(binary_expr)
    end

    def visit_grouping_expr(grouping_expr)
    end

    def visit_literal_expr(literal_expr)
      literal_token = literal_expr.literal_value

      case literal_token.type
      when :number_literal
        literal_token.string.to_f
      when :string_literal
        "#{literal_token.string.gsub('"', '')}"
      else
        # TODO: Raise, probably
      end
    end

    def visit_unary_expr(unary_expr)
    end
  end
end
