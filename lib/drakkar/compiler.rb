require_relative 'parser'
require_relative 'checker'

module Drakkar
  class Compiler

    def initialize
      header
    end

    def header
      puts "Drakkar LL(k) parser generator"
    end

    def compile filename
      begin
        puts "[+] compiling #{filename}"
        ast=Parser.new.parse(filename)
        Checker.new.check(ast)
      rescue Exception => e
        puts e.backtrace
        abort
      end
    end
  end
end

if $PROGRAM_NAME==__FILE__
  Drakkar::Compiler.new.compile ARGV.first
end
