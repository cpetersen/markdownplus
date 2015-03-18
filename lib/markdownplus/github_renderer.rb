require 'pygments'
require 'redcarpet'

module Markdownplus
  class GithubRenderer < Redcarpet::Render::HTML
    # alias_method :existing_block_code, :block_code
    def block_code(code, language)
      Pygments.highlight(code, lexer: language)
    end
  end
end
