require 'csv'
require 'json'
require 'open-uri'
require 'pygments'
require 'redcarpet'

module Markdownplus
  class Parser
    attr_reader :input
    attr_accessor :current_block

    def self.parse(value)
      parser = Parser.new(value)
      parser.parse
      parser
    end

    def initialize(value=nil)
      @input = value
    end

    def blocks
      @blocks ||= []
    end
    def blocks=(value)
      @blocks = value
    end

    def code_blocks
      blocks.select { |b| b.class == CodeBlock }
    end

    def executable_blocks
      code_blocks.select(&:executable?)
    end

    def markdown
      blocks.collect { |b| b.markdown }.join
    end

    def html
      markdown_renderer.render(markdown)
    end

    def markdown_renderer
      Redcarpet::Markdown.new(BootstrapRenderer, fenced_code_blocks: true)
    end

    def lines
      @lines ||= input.split("\n")
    end

    def errors
      blocks.collect { |b| b.errors }.flatten
    end

    def warnings
      blocks.collect { |b| b.warnings }.flatten
    end

    def each_line(&block)
      if block_given?
        lines.each do |line|
          block.call(line)
        end
      end
    end

    def parse
      each_line do |line|
        matcher = line.match(/\s*`{3,}\s*(\S*)\s*/)
        if matcher
          if self.current_block && self.current_block.is_a?(CodeBlock)
            self.blocks << self.current_block
            self.current_block = nil
          else
            self.blocks << self.current_block if self.current_block
            self.current_block = CodeBlock.new(matcher[1])
          end
        else
          self.current_block ||= TextBlock.new
          self.current_block.append line
        end
      end
      self.blocks << self.current_block if self.current_block      
    end

    def execute
      self.executable_blocks.each do |block|
        block.execute
      end
    end
  end

  class Block
    def input
      @input ||= ""
    end
    def input=(value)
      @input = value
    end

    def lines
      self.input.split("\n")
    end

    def append(line)
      self.input += "#{line}\n"
    end

    def errors
      @errors ||= []
    end

    def warnings
      @warnings ||= []
    end
  end

  class TextBlock < Block
    def markdown
      self.input
    end
  end

  class CodeBlock < Block
    attr_reader :directive, :program
    attr_accessor :output

    def initialize(value=nil)
      @directive = value

      if @directive.match(/\(/)
        begin
          @program ||= Markdownplus::DirectiveParser.parse(@directive)
        rescue => e
          errors << e.message
        end
      end
    end

    def functions
      program.functions if program!=nil
    end

    def executable?
      (functions!=nil && functions.size>0)
    end

    def execute
      self.output = self.input
      if functions
        self.functions.each do |function|
          handler = HandlerRegistry.handler_instance(function.function_name)
          if handler
            self.output = handler.execute(output, function.function_parameters, warnings, errors)
          else
            self.errors << "No handler defined for [#{function.function_name}]"
          end
        end
      end
      self.output
    end

    def markdown
      s = input
      if s.end_with?("\n")
        result = "```#{directive}\n#{input}```\n"
      else
        result = "```#{directive}\n#{input}\n```\n"
      end
    end

    def output_lines
      self.output.split("\n") if self.output
    end
  end
end

