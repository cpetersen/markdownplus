require 'treetop'

module Markdownplus
  module Literals
    class ExpressionLiteral < Treetop::Runtime::SyntaxNode
      def functions
        _functions(self.elements).flatten.compact
      end

      def _functions(elements)
        return unless elements
        results = elements.select { |e| e.class==Markdownplus::Literals::FunctionLiteral }
        elements.each do |element|
          if [Treetop::Runtime::SyntaxNode, Markdownplus::Literals::ExpressionLiteral, Markdownplus::Literals::TransformationLiteral].include?(element.class)
            results << _functions(element.elements)
          end
        end
        results
      end
      def symbols
        self.elements.select { |e| e.class==SymbolLiteral }
      end
      def parens
        self.elements.select { |e| e.class==ParensLiteral }
      end
    end

    class TransformationLiteral < ExpressionLiteral
      #Specific subclass, the root should only match this
    end

    class FunctionLiteral < ExpressionLiteral
      def function_name
        self.symbols[0].text_value.strip
      end

      def function_parameters
        self.parens.first.function_parameters
      end

      def function_parameter_values(input, warnings, errors)
        self.parens.first.function_parameters.collect { |fp| fp.value(input, warnings, errors) }
      end

      def execute(input, warnings, errors)
        handler = HandlerRegistry.handler_instance(self.function_name)
        if handler
          output = handler.execute(input, self.function_parameter_values(nil, warnings, errors), warnings, errors)
        else
          self.add_error("No handler defined for [#{self.function_name}]")
        end
        output
      end

      def value(input, warnings, errors)
        execute(input, warnings, errors)
      end

    end

    class ParensLiteral < ExpressionLiteral
      def function_parameters
        self.find_parameters(self.elements)
      end

      def find_parameters(elements, params=[])
        return params unless elements
        elements.each do |element|
          if [StringLiteral, SymbolLiteral, FunctionLiteral].include?(element.class)
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

      def value(input, warnings, errors)
        to_s
      end
    end

    class SymbolLiteral < ExpressionLiteral
      def to_s
        self.text_value.strip
      end

      def value(input, warnings, errors)
        to_s
      end
    end
  end
end

