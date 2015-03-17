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
end
