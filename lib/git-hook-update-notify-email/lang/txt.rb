require 'syntax'

module Syntax

  # A tokenizer for the Ruby language. It recognizes all common syntax
  # (and some less common syntax) but because it is not a true lexer, it
  # will make mistakes on some ambiguous cases.
  class Txt < Tokenizer

    # Step through a single iteration of the tokenization process.
    def step
      start_group :normal, @text
      end_group :normal
    end
  end

  SYNTAX["txt"] = Txt

end
