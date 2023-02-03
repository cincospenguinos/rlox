# frozen_string_literal: true

module Rlox
  class AstStringifier
    def stringify(expression)
      expression.accept(self)
    end

    def visit_binary_expr(binary_expr)
      "(#{binary_expr.operator_token} #{binary_expr.left_expression} #{binary_expr.right_expression})"
    end

    def visit_grouping_expr(grouping_expr)
    end

    def visit_literal_expr(literal_expr)
    end

    def visit_unary_expr(unary_expr)
    end
  end
end
