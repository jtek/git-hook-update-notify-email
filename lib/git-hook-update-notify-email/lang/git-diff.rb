require 'syntax'

module Syntax

  # A tokenizer for the Ruby language. It recognizes all common syntax
  # (and some less common syntax) but because it is not a true lexer, it
  # will make mistakes on some ambiguous cases.
  class GitDiff < Tokenizer

    def check_diff
      check_head_diff
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

    def check_head_diff
      case
        when bol? && check(/diff --git/)
          start_group :normal, scan_until(/\n/)
          file_path = self.chunk[/diff --git a(.+) b(.+)/, 1]
          @file_ext = File.extname(file_path)[1,10]
        when bol? && check(/\+\+\+/)
          start_group :normal, scan_until(/\n/)
        when bol? && check(/---/)
          start_group :normal, scan_until(/\n/)
        when bol? && check(/index/)
          start_group :normal, scan_until(/\n/)
        when bol? && check(/@@@/)
          start_group :normal, scan_until(/\n/)
          end_group :normal
      end
    end

    def associate
      associate = {'rb' => 'ruby', 
        'xml' => 'xml', 
        'html' => 'xml',
        'erb' => 'xml',
        'yaml' => 'yaml'}
      if associate.key? @file_ext
        associate[@file_ext]
      else
        'txt'
      end
    end

    # Step through a single iteration of the tokenization process.
    def step
      check_diff
      while not eos?
        subtokenize(associate, scan_until(/\n/))
        check_diff
      end
    end
  end

  SYNTAX["git-diff"] = GitDiff

end
