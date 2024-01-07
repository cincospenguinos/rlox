# frozen_string_literal: true

## THIS IS AN AUTOGENERATED FILE--DO NOT EDIT
module Rlox
  class Expr
  end

  class BinaryExpr < Expr
    attr_reader :left_expression, :operator_token, :right_expression

    def initialize(left_expression, operator_token, right_expression)
      @left_expression = left_expression
      @operator_token = operator_token
      @right_expression = right_expression
    end

    def accept(visitor)
      visitor.visit_binary_expr(self)
    end
  end

  class GroupingExpr < Expr
    attr_reader :expression

    def initialize(expression)
      @expression = expression
    end

    def accept(visitor)
      visitor.visit_grouping_expr(self)
    end
  end

  class LiteralExpr < Expr
    attr_reader :literal_value

    def initialize(literal_value)
      @literal_value = literal_value
    end

    def accept(visitor)
      visitor.visit_literal_expr(self)
    end
  end

  class UnaryExpr < Expr
    attr_reader :operator_token, :right_expression

    def initialize(operator_token, right_expression)
      @operator_token = operator_token
      @right_expression = right_expression
    end

    def accept(visitor)
      visitor.visit_unary_expr(self)
    end
  end
end
