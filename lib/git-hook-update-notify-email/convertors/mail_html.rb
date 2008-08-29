require 'syntax/convertors/abstract'

module Syntax
  module Convertors

    # A simple class for converting a text into HTML.
    class MailHTML < Abstract

      # Converts the given text to HTML, using spans to represent token groups
      # of any type but <tt>:normal</tt> (which is always unhighlighted). If
      # +pre+ is +true+, the html is automatically wrapped in pre tags.
      def convert( text, pre=true )
        html = ""
        html << "<pre>" if pre
        regions = []
        @tokenizer.tokenize( text ) do |tok|
          value = html_escape(tok)
          case tok.instruction
            when :region_close then
              regions.pop
              html << "</span>"
            when :region_open then
              regions.push tok.group
              html << "<span style=\"#{style(tok.group)}\">#{value}"
            else
              if tok.group == ( regions.last || :normal )
                html << value
              else
                html << "<span style=\"#{style(tok.group)}\">#{value}</span>"
              end
          end
        end
        html << "</span>" while regions.pop
        html << "</pre>" if pre
        html
      end

      private

        # Replaces some characters with their corresponding HTML entities.
        def html_escape( string )
          string.gsub( /&/, "&amp;" ).
                 gsub( /</, "&lt;" ).
                 gsub( />/, "&gt;" ).
                 gsub( /"/, "&quot;" )
        end

        def style(group)
          case group
          when :comment
            'color: #005; font-style: italic;'
          when :keyword
            'color: #A00; font-weight: bold;'
          when :method
            'color: #077;'
          when :class
            'color: #074;'
          when :module
            'color: #050;'
          when :punct
            'color: #447; font-weight: bold;'
          when :symbol
            'color: #099;'
          when :string
            'color: #944; background: #FFE;'
          when :char
            'color: #F07;'
          when :ident
            'color: #004;'
          when :constant
            'color: #07F;'
          when :regex
            'color: #B66; background: #FEF;'
          when :number
            'color: #F99;'
          when :attribute
            'color: #5bb;'
          when :global
            'color: #7FB;'
          when :expr
            'color: #227;'
          when :escape
            'color: #277;'
          else
            ''
          end
        end
    end
  end
end
