require_relative 'parser'
require_relative 'checker'

module Drakkar
  class Compiler

    attr_accessor :options

    def initialize
      header
    end

    def header
      puts "Drakkar LL(k) parser generator"
    end

    def compile filename
      begin
        puts "[+] analyzing #{filename}"
        ast=Parser.new.parse(filename)

        Checker.new.check(ast)
        exiting :check

      rescue Exception => e
        puts e
        puts e.backtrace
        abort
      end
    end

    def exiting option
      if $options[option]
        puts "[+] exit on option '#{option}'"
        abort
      end
    end
  end
end

if $PROGRAM_NAME==__FILE__
  Drakkar::Compiler.new.compile ARGV.first
end
