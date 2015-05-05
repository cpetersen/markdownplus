module Markdownplus
  class Handler
    def execute(input, parameters, variables, warnings, errors)
    end
  end

  class IncludeHandler < Handler
    def execute(input, parameters, variables, warnings, errors)
      output = nil
      warnings << "Include handler ignores input" if(input!=nil && !input.strip.empty?)
      if parameters==nil
        errors << "No url given"
      elsif parameters.count == 0
        errors << "No url given"
      else
        begin
          output = IncludeHandler.cached(parameters.first.to_s)
        rescue => e
          errors << "Error opening [#{parameters.first}] [#{e.message}]"
        end
      end
      output
    end

    @@cache = {}
    def self.cached(url)
      return @@cache[url] if @@cache[url]
      @@cache[url] = open(url).read
      @@cache[url]
    end
  end
  HandlerRegistry.register("include", IncludeHandler)

  class Csv2HtmlHandler < Handler
    def execute(input, parameters, variables, warnings, errors)
      if input
        output = "<table class='table table-striped'>"
        row_num = 0
        CSV.parse(input) do |row|
          if row_num == 0
            output += "<thead><tr>#{row.collect { |c| "<th>#{c}</th>"}.join}</tr></thead>\n<tbody>\n"
          else
            output += "<tr>#{row.collect { |c| "<td>#{c}</td>"}.join}</tr>\n"
          end
          row_num += 1
        end
        output += "</tbody></table>"
        output
      else
        errors << "No input given"
        ""
      end
    end
  end
  HandlerRegistry.register("csv2html", Csv2HtmlHandler)

  class DropColumnsHandler < Handler
    def execute(input, parameters, variables, warnings, errors)
      skip_cols = parameters.collect { |p| p.to_i }
      if skip_cols.empty?
        warnings << "No columns given"
        input
      else
        CSV.generate do |csv|
          CSV.parse(input) do |row|
            new_row = []
            row.each_with_index do |cell, col_num|
              new_row << cell unless skip_cols.include?(col_num)
            end
            csv << new_row
          end
        end
      end
    end
  end
  HandlerRegistry.register("drop_columns", DropColumnsHandler)

  class PrettyJsonHandler < Handler
    def execute(input, parameters, variables, warnings, errors)
      begin
        obj = JSON.parse(input)
        output = JSON.pretty_generate(obj)
      rescue => e
        output = input
        errors << "Invalid json"
      end
      "```json\n#{output}\n```"
    end
  end
  HandlerRegistry.register("pretty_json", PrettyJsonHandler)

  class StripWhitespaceHandler < Handler
    def execute(input, parameters, variables, warnings, errors)
      input.gsub(/\s*\n\s*/,"\n")
    end
  end
  HandlerRegistry.register("strip_whitespace", StripWhitespaceHandler)

  class RawHandler < Handler
    def execute(input, parameters, variables, warnings, errors)
      "```raw\n#{input}\n```"
    end
  end
  HandlerRegistry.register("raw", RawHandler)

  class EmptyHandler < Handler
    def execute(input, parameters, variables, warnings, errors)
      ""
    end
  end
  HandlerRegistry.register("empty", EmptyHandler)

  ### START VARIABLES ###
  class SetHandler < Handler
    def execute(input, parameters, variables, warnings, errors)
      if parameters==nil
        errors << "No variable name given"
      elsif parameters.count == 0
        errors << "No variable name given"
      else
        warnings << "More than one variable name given [#{parameters.inspect}]" if parameters.count > 1
        variables[parameters.first.to_s] = input
      end
      input
    end
  end

  class GetHandler < Handler
    def execute(input, parameters, variables, warnings, errors)
      output = input
      if parameters==nil
        errors << "No variable name given"
      elsif parameters.count == 0
        errors << "No variable name given"
      else
        warnings << "More than one variable name given [#{parameters.inspect}]" if parameters.count > 1
        output = variables[parameters.first.to_s]
      end
      output
    end
  end

  HandlerRegistry.register("set", SetHandler)
  HandlerRegistry.register("get", GetHandler)
  #### END VARIABLES ####
end
