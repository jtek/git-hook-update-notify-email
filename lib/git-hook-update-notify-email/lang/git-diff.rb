require 'coderay'
require 'coderay/encoders/html'
require 'coderay/styles/cycnus'

module CodeRay
  module Styles
    class GitHook < Cycnus
      register_for :git_hook
      TOKEN_COLORS = Cycnus::TOKEN_COLORS + ".add { background-color:red } \n .del {background-color:yellow }"
    end
  end
end

module CodeRay
  module Encoders
    class Git < HTML
      register_for :git
      ClassOfKind.update with = {
        :add => 'add',
        :del => 'del',
      }
    end
  end
end

module CodeRay
module Scanners

  load :ruby
  load :html
  load :plain
  load :c

  class GitDiff < Scanner


    include Streamable

    register_for :git_diff

    def setup
      @ruby_scanner = CodeRay.scanner :ruby, :tokens => @tokens, :keep_tokens => true
      @c_scanner = CodeRay.scanner :c, :tokens => @tokens, :keep_tokens => true
      @html_scanner = CodeRay.scanner :html, :tokens => @tokens, :keep_tokens => true, :keep_state => true
      @plain_scanner = CodeRay.scanner :plain, :tokens => @tokens, :keep_tokens => true
    end

    def associate
      associate = {'rb' => @ruby_scanner,
        'xml' => @html_scanner, 
        'html' => @html_scanner,
        'erb' => @html_scanner,
        'c' => @c_scanner,
        'cpp' => @c_scanner,
        'h' => @c_scanner}
      if associate.key? @file_ext
        associate[@file_ext]
      else
        @plain_scanner
      end
    end

    def check_diff
      check_head_diff
      if check(/\+/)
        if @del
          @tokens << [:close, :del]
          @del = false
        end
        unless @add
          @tokens << [:open, :add]
        end
        @add = true
      elsif check(/-/)
        if @add
          @tokens << [:close, :add]
          @add = false
        end
        unless @del
          @tokens << [:open, :del]
        end
        @del = true
      else
        if @add
          @tokens << [:close, :add]
          @add = false
        elsif @del
          @tokens << [:close, :del]
          @del = false
        end
      end
    end

    def check_head_diff
      text = ''
      case
        when bol? && check(/diff --git/)
          text = scan_until(/\n/)
          file_path = text[/diff --git a(.+) b(.+)/, 1]
          @file_ext = File.extname(file_path)[1,10]
        when bol? && check(/\+\+\+/)
          text = scan_until(/\n/)
        when bol? && check(/---/)
          text = scan_until(/\n/)
        when bol? && check(/index/)
          text = scan_until(/\n/)
        when bol? && check(/@@@/)
          text = scan_until(/\n/)
        when bol? && check(/@@/)
          text = scan_until(/\n/)
      end
      @plain_scanner.tokenize text if text != ''
    end

    # Step through a single iteration of the tokenization process.
    def scan_tokens (token, options)
      check_diff
      while not eos?
        associate.tokenize scan_until(/\n/)
        check_diff
      end
      if @add
        @tokens << [:close, :add]
      elsif @del
        @tokens << [:close, :del]
      end
      @tokens
    end
  end

end
end
