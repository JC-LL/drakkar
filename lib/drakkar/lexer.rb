require_relative 'generic_lexer'

module Drakkar

  class Lexer < GenericLexer

    def initialize
      super
      ignore /\s+/
      keyword "grammar"
      keyword "end"
      token :alt              => /\|/
      token :qmark            => /\?/
      token :star             => /\*/
      token :lparen           => /\(/
      token :rparen           => /\)/
      token :lbrace           => /\{/
      token :rbrace           => /\}/
      token :define           => /::=/
      token :semicolon        => /;/
      token :colon            => /:/
      token :comma            => /\,/
      token :comment          => /\#(.*)/

      token :eq               => /\=/
      # .............literals..............................
      token :regexp           => /\/(.*)\//
      token :ident            => /\A[a-zA-Z]\w*/i
      token :float_lit        => /\A\d*(\.\d+)(E([+-]?)\d+)?/
      token :integer_lit      => /\A(0x[0-9a-fA-F]+)|\d+/
      token :string_lit       => /\A'[^']*'/
      token :char_lit         => /\A'\\?.'/
      #token :lexer_warning    => /./

    end
  end
end
