require 'treetop'

module Markdownplus
  class DirectiveParser
    def self.parse(data)
      Treetop.load("lib/markdownplus/directives")
      @@parser ||= TransformationParser.new
      tree = @@parser.parse(data)
      # If the AST is nil then there was an error during parsing
      # we need to report a simple error message to help the user
      raise "Parse error at offset: #{@@parser.index}" if(tree.nil?)

      return tree
    end
  end
end

