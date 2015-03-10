require 'csv'
require 'json'
require 'open-uri'
require 'pygments'
require 'redcarpet'

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

    def markdown
      blocks.collect { |b| b.markdown }.join
    end

    def html
      markdown_renderer.render(markdown)
    end

    def markdown_renderer
      Redcarpet::Markdown.new(Bootstrap2Renderer, fenced_code_blocks: true)
    end

    def lines
      @lines ||= source.split("\n")
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
        block.include
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

    def errors
      @errors ||= []
    end

    def warnings
      @warnings ||= []
    end
  end

  class TextBlock < Block
    def markdown
      self.source
    end
  end

  class CodeBlock < Block
    attr_reader :directives

    def initialize(value=nil)
      @directives = value.split("|").collect{|v| v.strip} if value
    end

    def markdown
      s = source
      if s.end_with?("\n")
        result = "```#{directives.join("|")}\n#{source}```\n"
      else
        result = "```#{directives.join("|")}\n#{source}\n```\n"
      end
    end

    def includable?
      first_directive == "include"
    end

    def executable?
      first_directive == "execute"
    end

    def include
      if includable?
        if lines.count == 0
          self.warnings << "No url given"
        else
          self.warnings << "More than one line given" if lines.count > 1
          begin
            self.source = open(lines.first).read
          rescue => e
            self.errors << "Error opening [#{lines.first}] [#{e.message}]"
          end
        end
        directives.shift
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

  class Bootstrap2Renderer < Redcarpet::Render::HTML
    # alias_method :existing_block_code, :block_code
    def block_code(code, language)
      if language == "csv"
        result = "<table class='table table-striped'>"
        row_num = 0
        CSV.parse(code) do |row|
          if row_num == 0
            result += "<thead><tr>#{row.collect { |c| "<th>#{c}</th>"}.join}</tr></thead>\n<tbody>\n"
          else
            result += "<tr>#{row.collect { |c| "<td>#{c}</td>"}.join}</tr>\n"
          end
          row_num += 1
        end
        result += "</tbody></table>"
      elsif language == "formatted_json"
        begin
          obj = JSON.parse(code)
          result = Pygments.highlight(JSON.pretty_generate(obj), lexer: "json")
        rescue => e
          result = Pygments.highlight(code, lexer: "json")
        end
      else
        result = Pygments.highlight(code, lexer: language)
      end
      result
    end
  end
end

