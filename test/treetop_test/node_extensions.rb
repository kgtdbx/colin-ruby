module Sexp
#  Expression eg: (1 2 3)
#  Identifier eg: foo, bar, other_thing
#  IntegerLiteral eg: 1, 2, 99
#  StringLiteral eg: “test”
#  class CommaMark < Treetop::Runtime::SyntaxNode
#    def to_array
#      return self.text_value
#    end
#  end
#  class PeriodMark < Treetop::Runtime::SyntaxNode
#    def to_array
#      return self.text_value
#    end
#  end
  class IntegerLiteral < Treetop::Runtime::SyntaxNode
    def to_array
      return self.text_value.to_i
    end
  end
  class StringLiteral  < Treetop::Runtime::SyntaxNode
    def to_array
      return eval(self.text_value)
    end
  end
  class FloatLiteral  < Treetop::Runtime::SyntaxNode
    def to_array
      return self.text_value.to_i
    end
  end
  class Identifier  < Treetop::Runtime::SyntaxNode
    def to_array
      return self.text_value.to_sym
    end
  end
  class Expression  < Treetop::Runtime::SyntaxNode
    def to_array
      return self.elements[0].to_array
    end
  end
  class Body  < Treetop::Runtime::SyntaxNode
    def to_array
      return self.elements.map {|x| x.to_array}
    end
  end
end