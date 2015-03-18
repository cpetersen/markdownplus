module Markdownplus
  class Handler
    def execute(input, parameters, warnings, errors)
    end
  end

  class IncludeHandler < Handler
    def execute(input, parameters, warnings, errors)
      output = nil
      warnings << "Include handler ignores input" if(input!=nil && !input.strip.empty?)
      if parameters==nil
        errors << "No url given"
      elsif parameters.count == 0
        errors << "No url given"
      else
        begin
          output = open(parameters.first.to_s).read
        rescue => e
          errors << "Error opening [#{parameters.first}] [#{e.message}]"
        end
      end
      output
    end
  end
  HandlerRegistry.register("include", IncludeHandler)

  class CsvHandler < Handler
    def execute(input, parameters, warnings, errors)
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
    end
  end
  HandlerRegistry.register("csv", CsvHandler)

  class FormattedJsonHandler < Handler
    def execute(input, parameters, warnings, errors)
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
  HandlerRegistry.register("formatted_json", FormattedJsonHandler)
end
