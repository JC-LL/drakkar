module Drakkar

  class AstNode
  end

  class Grammar < AstNode
    attr_accessor :name,:rules
    def initialize
      @rules=[]
    end
  end

  class Rule < AstNode
    attr_accessor :name,:definition
  end

  class Seq < AstNode
    attr_accessor :elements
    def initialize element=nil
      @elements=[element]
      @elements.compact!
    end

    def <<(e)
      @elements << e
    end
  end

  class Alt < Seq
  end

  class Zerom < Seq
  end

  class Onem < Seq
  end

  class Maybe < Seq
  end

  class RegexpDef < AstNode
    attr_accessor :tok
    def initialize tok
      @tok=tok
    end

    def inspect
      tok.val
    end
  end

  class TokDef < AstNode
    attr_accessor :tok
    def initialize tok
      @tok=tok
    end

    def inspect
      tok.val
    end
  end

  class Ident < AstNode
    attr_accessor :tok
    def initialize tok
      @tok=tok
    end
  end
end
