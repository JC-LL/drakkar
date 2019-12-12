require 'colorize'

require_relative 'path'

CHECK_MARK = " \u2714"
ERROR_MARK = " \u2717"

CHECK=CHECK_MARK.encode('utf-8').green
ERROR=ERROR_MARK.encode('utf-8').red

module Drakkar

  class Checker

    attr_accessor :grammar

    def check grammar
      @grammar=grammar
      puts " |->[+] checking grammar"
      check_uniq_rule_names
      check_completeness
      check_ll_1
      print_result
    end

    def print_result
      if @total_errors==0
        puts message(0,"[+] result : "+"your grammar is LL(1)")
      else
        puts message(0,"[+] result : "+"your grammar is NOT LL(1)")
      end
    end

    def check_completeness
      begin
        print "     |->[+] check use/def "
        @name_rule={}
        grammar.rules.each{|rule| @name_rule[rule.name]=rule.definition}
        @links={}
        grammar.rules.each do |rule|
          rec_completeness(rule.definition)
        end
        puts CHECK_MARK.encode('utf-8').green
      rescue Exception => e
        puts "\nCHECKING ERROR : #{e}"
        abort
      end
    end

    def rec_completeness element,indent=0
      case seq=str=tok_def=regexp_def=element
      when Alt, Seq, Onem, Zerom
        seq.elements.each_with_index do |elem,idx|
          @links[elem]||=rec_completeness(elem,indent+1)
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

    def check_ll_1
      puts "     |->[+] check LL(1)"
      # if alternatives : check that the first part of the rule leads, in the branches, to
      # a unique tokenDef.
      @total_errors=0
      @max_indent=grammar.rules.collect{|rule| rule.name.size}.max
      @paths={}
      grammar.rules.each{|rule|
        @rule_errors=0
        print message(9,"|->[+] rule '#{rule.name}'").ljust(@max_indent+3)

        compute_paths(rule)
        check_rule_paths(rule)

        @total_errors+=@rule_errors
        puts CHECK unless @rule_errors!=0
      }
    end

    def compute_paths rule
      begin
        @paths[rule.name]=paths=rec_paths(rule.definition)
      rescue Exception => e
        puts e
        puts e.backtrace
      end
    end

    def check_rule_paths rule
      paths_ends=@paths[rule.name].collect{|path| path.last}
      dupl_count = Hash.new(0)
      paths_ends.each{|v| dupl_count.store(v, dupl_count[v]+1) }
      duplicates=dupl_count.select{|k,v| v>1}
      if duplicates.any?
        duplicates.each do |end_,count|
          puts
          puts message(13,"|->[+] not LL(1). starter '#{end_}' reached #{count} times" + ERROR)
          erroneous_paths=@paths[rule.name].select{|path| path.ends_with?(end_)}
            erroneous_paths.each do |err_path|
              puts message(17,"|->[+] path #{err_path.str}")
            end
        end
        @rule_errors+=1
      end
    end

    def message indent, str
      " "*indent+str
    end

    def rec_paths element
      if paths=@paths[element]
        return paths
      end # memoization

      case alt=seq=zerom=onem=tokdef=regexpdef=str=element
      when Alt
        paths=alt.elements.collect{|elem| rec_paths(elem)}
      when Seq
        paths=rec_paths(seq.elements[0])
      when Zerom
        paths=rec_paths(seq.elements[0])
      when Onem
        paths=rec_paths(seq.elements[0])
      when TokDef
        paths = []
        paths << path=Path.new
        path << tokdef
      when RegexpDef
        paths = []
        paths << path=Path.new
        path << regexpdef
      when String
        paths=[]
        rec_paths(@name_rule[str]).each do |path|
          new_path=Path.new
          new_path << str
          new_path.merge! path
          paths << new_path
        end
      else
        raise "unknown element for rec_paths : #{element.class}"
      end
      paths.flatten!
      @paths[element]=paths.clone #memoization
      return paths
    end

  end
end
