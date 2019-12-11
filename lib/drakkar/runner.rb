require "optparse"

require_relative "compiler"

module Drakkar

  class Runner

    def self.run *arguments
      new.run(arguments)
    end

    def run arguments
      compiler=Compiler.new
      compiler.options = args = parse_options(arguments)
      $options=compiler.options

      if filename=args[:filename]
        compiler.compile filename
      else
        puts "need a grammar file : drakkar <file.gram>"
      end
    end

    private
    def parse_options(arguments)

      size=arguments.size

      parser = OptionParser.new

      options = {}

      parser.on("-h", "--help", "Show help message") do
        puts parser
        exit(true)
      end

      parser.on("-v", "--version", "Show version number") do
        puts VERSION
        exit(true)
      end

      parser.on("--verbose", "verbose mode") do
        options[:verbose]=true
        $verbose=true
      end

      parser.on("-c", "--check", "check grammar") do
        options[:check]=true
      end

      parser.parse!(arguments)

      options[:filename]=arguments.shift

      if arguments.any?
        puts "WARNING : superfluous arguments : #{arguments}"
      end

      if size==0
        puts parser
      end

      options
    end
  end
end
