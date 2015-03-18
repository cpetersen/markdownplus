require 'pygments'
require 'redcarpet'

module Markdownplus
  class GithubRenderer < Redcarpet::Render::HTML
    # alias_method :existing_block_code, :block_code
    def block_code(code, language)
      begin
        Pygments.highlight(code, lexer: language)
      rescue
        "<pre><code>#{code}</code></pre>"
      end
    end
  end
end
