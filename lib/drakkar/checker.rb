require 'colorize'

CHECK_MARK = " \u2714"
ERROR_MARK = " \u2717"
#CHECKMARK = " \u2705"

module Drakkar
  class Checker
    attr_accessor :grammar
    def check grammar
      @grammar=grammar
      puts " |->[+] checking grammar"
      link_defs
      check_uniq_rule_names
      check_alt_ll_1
      if @errors==0
        puts " "*15+"your grammar is LL(1)"
      end
    end

    def link_defs
      begin
        print "     |->[+] linking use/def "
        @name_rule={}
        grammar.rules.each{|rule| @name_rule[rule.name]=rule.definition}
        @links={}
        grammar.rules.each do |rule|
          rec_link(rule.definition)
        end
        puts CHECK_MARK.encode('utf-8').green
      rescue Exception => e
        puts "\nCHECKING ERROR : #{e}"
        abort
      end
    end

    def rec_link element,indent=0
      case seq=str=tok_def=regexp_def=element
      when Alt, Seq, Onem, Zerom
        seq.elements.each_with_index do |elem,idx|
          @links[elem]||=rec_link(elem,indent+1)
          seq.elements[idx]=@links[elem]
        end
        return seq
      when String
        rule=@name_rule[str]
        if rule.nil?
          raise "unknown rule for '#{str}'"
        else
          return rule
        end
      when TokDef
        return tok_def
      when RegexpDef
        return regexp_def
      else
        raise "unknown #{element}"
      end
    end

    def check_uniq_rule_names
      print "     |->[+] uniqueness "
      names=grammar.rules.map{|rule| rule.name}
      if (diff=names.size-names.uniq.size)!=0
        add_s=diff>1 ? "s" :""
        puts "error : #{diff} rule#{add_s} defined several times"
        doubles=names-names.uniq
        puts doubles
      else
        puts CHECK_MARK.encode('utf-8').green
      end
    end

    def check_alt_ll_1
      puts "     |->[+] check ll(k)"
      # if alternatives : check that the first part of the rule leads, in the branches, to
      # a unique tokenDef.
      @max_indent=grammar.rules.collect{|rule| rule.name.size}.max
      grammar.rules.each{|rule| find_starters(rule)}
    end

    def find_starters rule
      message="         |->[+] starters for rule "
      print message+" '#{rule.name}'".ljust(@max_indent+3)
      @starters={}
      @errors=0
      starters=rec_starters(rule.definition)
      hash_count=starters.inject(Hash.new(0)) {|h,i| h[i] += 1; h }
      hash_count.each do |elem,count|
        if count>1
          print ERROR_MARK.encode('utf-8').red
          puts " not LL(1) : #{elem.inspect} reached #{count} times".ljust(100)
          @errors+=1
        end
      end
      puts CHECK_MARK.encode('utf-8').green unless @errors!=0
    end

    def rec_starters element
      if starters=@starters[element]
        return starters
      end
      case alt=seq=zerom=onem=tokdef=regexpdef=element
      when Alt
        ret=alt.elements.collect{|elem| rec_starters(elem)}
      when Seq
        ret=rec_starters(seq.elements[0])
      when Zerom
        ret=rec_starters(seq.elements[0])
      when Onem
        ret=rec_starters(seq.elements[0])
      when TokDef
        ret=[tokdef]
      when RegexpDef
        ret=[regexpdef]
      else
        raise "unknown element for rec_starters : #{element.class}"
      end
      ret.flatten!
      @starters[element]=ret
      ret
    end

  end
end
