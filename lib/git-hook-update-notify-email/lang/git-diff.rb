require 'syntax'

module Syntax

  # A tokenizer for the Ruby language. It recognizes all common syntax
  # (and some less common syntax) but because it is not a true lexer, it
  # will make mistakes on some ambiguous cases.
  class GitDiff < Tokenizer

    def check_diff
      if check(/\+/)
        unless @comment.nil?
          end_region(@comment)
        end
        start_region(:add)
        @comment = :add
      elsif check(/-/)
        unless @comment.nil?
          end_region(@comment)
        end
        start_region(:del)
        @comment = :del
      else
        unless @comment.nil?
          end_region(@comment)
          @comment = nil
        end
      end
    end

    # Step through a single iteration of the tokenization process.
    def step
      check_diff
      while not eos?
        subtokenize('ruby', scan_until(/\n/))
        check_diff
      end
    end
  end

  SYNTAX["git-diff"] = GitDiff

end
