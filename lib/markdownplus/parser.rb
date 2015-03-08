require 'open-uri'

module Markdownplus
  class Parser
    attr_reader :source
    attr_accessor :current_block

    def self.parse(value)
      parser = Parser.new(value)
      parser.parse
      parser
    end

    def initialize(value=nil)
      @source = value
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

    def includable_blocks
      code_blocks.select(&:includable?)
    end

    def executable_blocks
      code_blocks.select(&:executable?)
    end

    def lines
      @lines ||= source.split("\n")
    end

    def errors
      @errors ||= []
    end

    def warnings
      @warnings ||= []
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
          if self.current_block && self.current_block.class == CodeBlock
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

    def include
      includable_blocks.each do |block|
        block.include(self.warnings, self.errors)
      end
    end
  end

  class Block
    def source
      @source ||= ""
    end
    def source=(value)
      @source = value
    end

    def lines
      self.source.split("\n")
    end

    def append(line)
      self.source += "#{line}\n"
    end
  end

  class TextBlock < Block
  end

  class CodeBlock < Block
    attr_reader :directives

    def initialize(value=nil)
      @directives = value.split("|").collect{|v| v.strip} if value
    end

    def includable?
      first_directive == "include"
    end

    def executable?
      first_directive == "execute"
    end

    def include(warnings=[], errors=[])
      if includable?
        if lines.count == 0
          warnings << "No url given"
        else
          warnings << "More than one line given" if lines.count > 1
        end
        begin
          self.source = open(lines.first).read
        rescue => e
          errors << "Error opening [#{lines.first}] [#{e.message}]"
        end
      end
    end

    def first_directive
      directives.first if directives
    end

    # def method
    #   matcher = directive.match(/(.*?)\((.*)\)/)
    #   if matcher
    #     method = matcher[1].strip
    #     params = matcher[2].split(",").collect { |p| p.strip }
    #   end
    # end
  end

  # class Value
  #   def self.parse(string)
  #     items = string.split(",").collect do |item|
  #       matcher = item.match(/(.*?)\((.*)\)/)
  #       if matcher
  #         name = matcher[1].strip
  #         params = parse(matcher[2])
  #         Method.new(name: name, params: params)
  #       else
  #         Param.new(item.strip)
  #       end
  #     end
  #   end
  # end

  # class Param < Value
  #   def initialize(v)
  #     @value = value
  #   end

  #   def value
  #     @value
  #   end
  # end

  # class Method < Value
  #   attr_reader :name
  #   attr_reader :params

  #   def initialize(opts={})
  #     @name = opts[:name]
  #     @params = opts[:params]
  #   end
  # end
end
