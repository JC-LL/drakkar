require_relative 'lexer'
require_relative 'ast'

module Drakkar

  class Parser
    attr_accessor :tokens
    # ........... helper methods ..........
    def acceptIt
      tokens.shift
    end

    def expect kind
      if ((actual=tokens.shift).kind)!=kind
        puts "PARSING ERROR :"
        raise "expecting '#{kind}'. Received '#{actual.val}' around #{actual.pos}"
      end
      return actual
    end

    def showNext(n=1)
      tokens[n-1] if tokens.any?
    end
    #............ parsing methods ...........
    def parse filename
      puts " |->[+] parsing  grammar"
      begin
        str=IO.read(filename)
        @tokens=Lexer.new.tokenize(str)
        @tokens.reject!{|tok| tok.is_a? [:newline]}
        @tokens.reject!{|tok| tok.is_a? [:comment]}
        $verbose =false
        pp @tokens if $verbose
        ast=parse_grammar()
      rescue Exception => e
        puts "PARSING ERROR : #{e}"
        puts "in grammar source at line/col #{showNext.pos}" if showNext
        puts e.backtrace
        abort
      end
    end

    def parse_grammar
      ret=Grammar.new
      puts "parse grammar" if $verbose
      expect :grammar
      ret.name=expect(:ident).val
      while !showNext.is_a?(:end)
        ret.rules << parse_rule(1)
      end
      expect :end
      ret
    end

    def parse_rule indent=0
      puts " "*indent+"parse rule" if $verbose
      ret=Rule.new
      ret.name=expect(:ident).val
      expect :define
      ret.definition=parse_alt(indent+1)
      expect :semicolon
      ret
    end

    def parse_alt indent=0
      puts " "*indent+"parse alt" if $verbose
      ret=Alt.new
      ret << parse_seq(indent+1)
      while showNext.is_a?(:alt)
        acceptIt
        ret << parse_seq(indent+1)
      end
      if ret.elements.size==1
        ret=ret.elements.first
      end
      ret
    end

    def parse_seq indent=0
      puts " "*indent+"parse_seq" if $verbose
      ret=Seq.new
      while !showNext.is_a? [:semicolon,:alt,:rparen]
        case showNext.kind
        when :ident
          ret << acceptIt.val
        when :string_lit
          ret << TokDef.new(acceptIt)
        when :regexp
          ret << RegexpDef.new(acceptIt)
        when :star
          acceptIt
          prev=ret.elements.pop
          ret << Zerom.new(prev)
        when :plus
          acceptIt
          prev=ret.elements.pop
          ret << Onem.new(prev)
        when :qmark
          acceptIt
          prev=ret.elements.pop
          ret << Maybe.new(prev)
        when :lparen
          ret << parse_parenth(indent+1)
        else
          raise "error in parse sequence. showNext : #{showNext.kind}"
        end
      end
      ret
    end

    def parse_parenth indent=0
      ret=Seq.new
      puts " "*indent+"parse_parenth" if $verbose
      expect :lparen
      ret << parse_alt(indent+1)
      expect :rparen
      ret
    end
  end
end
