module Markdownplus
  class BootstrapRenderer < Redcarpet::Render::HTML
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
