module Drakkar

  class Path
    attr_accessor :elements
    def initialize
      @elements=[]
    end

    def each &block
      @elements.each &block
    end

    def << e
      @elements << e
    end

    def merge! e
      case path=e
      when Path,Array
        path.each do |ee|
          self.merge! ee
        end
      else
        @elements << e
      end
      @elements.flatten!
    end

    def str
      tab=[]
      @elements.each do |e|
        if e.respond_to? :val
          tab << e.val
        else
          tab << e
        end
      end
      tab.join("->")
    end

    def ends_with? tok_or_regexp_str
      self.last==tok_or_regexp_str
    end

    def last
      last=@elements.last
      val=last.respond_to?(:val) ? last.val : last
      val
    end

  end
end
