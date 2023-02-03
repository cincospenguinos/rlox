# frozen_string_literal: true

module Rlox
  ## AstStringifier
  #
  # Stringifies expressions for debugging purposes
  class AstStringifier
    def stringify(expression)
      expression.accept(self)
    end

    def visit_binary_expr(binary_expr)
      parenthesize(binary_expr.operator_token.to_s, binary_expr.left_expression,
        binary_expr.right_expression)
    end

    def visit_grouping_expr(grouping_expr)
      parenthesize('group', grouping_expr.expression)
    end

    def visit_literal_expr(literal_expr)
      return 'nil' if literal_expr.literal_value.type == :nil
      literal_expr.literal_value.to_s
    end

    def visit_unary_expr(unary_expr)
      parenthesize(unary_expr.operator_token.to_s, unary_expr.right_expression)
    end

    private

    def parenthesize(expr_name, *exprs)
      str = "(#{expr_name}"

      exprs.each do |expr|
        str +=  " #{expr.accept(self)}"
      end

      "#{str})"
    end
  end
end
