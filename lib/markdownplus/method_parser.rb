require 'treetop'

module Markdownplus
  class MethodParser
    def self.parse(data)
      Treetop.load("lib/markdownplus/transformations")
      @@parser ||= TransformationParser.new
      tree = @@parser.parse(data)
      # If the AST is nil then there was an error during parsing
      # we need to report a simple error message to help the user
      if(tree.nil?)
        raise Exception, "Parse error at offset: #{@@parser.index}"
      end
      # self.clean_tree(tree)     
      return tree
    end

    private
    def self.clean_tree(root_node)
      return if(root_node.elements.nil?)
      root_node.elements.delete_if{|node| node.class.name == "Treetop::Runtime::SyntaxNode" }
      root_node.elements.each {|node| self.clean_tree(node) }
    end
  end

  module Literals
    class ExpressionLiteral < Treetop::Runtime::SyntaxNode
      def methods
        self.elements.select { |e| e.class==MethodLiteral }
      end
      def tokens
        self.elements.select { |e| e.class==TokenLiteral }
      end
      def parens
        self.elements.select { |e| e.class==ParensLiteral }
      end
    end

    class TransformationLiteral < ExpressionLiteral
      #Specific subclass, the root should only match this
    end

    class MethodLiteral < ExpressionLiteral
      def method_name
        self.tokens[0].text_value.strip
      end

      def method_parameters
        self.parens.first.method_parameters
      end
    end

    class ParensLiteral < ExpressionLiteral
      def method_parameters
        self.find_parameters(self.elements)
      end

      def find_parameters(elements, params=[])
        return params unless elements
        elements.each do |element|
          if [StringLiteral, TokenLiteral, MethodLiteral].include?(element.class)
            params << element 
          else
            find_parameters(element.elements, params)
          end
        end
        return params
      end
    end

    class StringLiteral < ExpressionLiteral
      def to_s
        v = self.text_value.strip
        v[1..v.length-2]
      end
    end

    class TokenLiteral < ExpressionLiteral
      def to_s
        self.text_value.strip
      end
    end
  end
end

