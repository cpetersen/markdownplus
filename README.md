# Markdownplus

Markdownplus extends [Github Flavored Markdown](https://help.github.com/articles/github-flavored-markdown/) by bringing programmatic features to the language portion of the fenced code blocks. A Markdownplus document can be transformed into a valid Markdown document, or taken all the way to html.

## Usage

### Syntax

Markdownplus files look like normal [Github Flavored Markdown](https://help.github.com/articles/github-flavored-markdown/) files. However, the fenced code blocks have most functionality. You can still use 

```markdown
  ```ruby
```

or

```markdown
  ```json
```

to add syntax hightlight, but you can also use a pipeline of functions to bring in other files, or perform more drastic formatting.

For instance, you could download a json file, format it, then highlight it as usual using:

```
  ```include('https://gist.githubusercontent.com/cpetersen/c6571117df132443ac81/raw/e5ac97e8e0665a0e4014ebc85ecef214763a7729/fake.json'),pretty_json()
```

or, you could download a csv file and turn it into an html table:

```
  ```include('https://gist.githubusercontent.com/cpetersen/b5a473ddf0b796cd9502/raw/e140bdc32ff2f6a600e357c2575220c0312a88ee/fake.csv'),csv2html()
```

### Execution

Given a markdown plus file, you can get the resulting Markdown using the following:

```ruby
require 'markdownplus'

parser = Markdownplus::Parser.parse(File.read("kitchensink.mdp")); nil
parser.execute; nil
puts parser.output_markdown; nil
```

If the resulting HTML is what you're interested in, you can use ```html```:

```ruby
require 'markdownplus'

parser = Markdownplus::Parser.parse(File.read("kitchensink.mdp")); nil
parser.execute; nil
puts parser.html; nil
```

## Function Pipeline

The function pipeline is the heart of Markdownplus. 

### Functions

A function looks like:

```
function_name()
function_name(symbol_parameter)
function_name("string parameter", 'other string parameter')
function_name(mix, 'and', match, "parameters")
function_name(you, "may pass", nested_methods("also"))
```

The first function in the pipeline gets the contents of the fenced code block as input. For instance:

```
   ```pretty_json()
   {"a":1,"b":2,"c":3}
```

would get `{"a":1,"b":2,"c":3}` as the input variable.

### Pipeline

You create pipeline, you string multiple functions together with a comma:

```
  ```include("some url"), csv2html()
```

In this case, the first function (include) gets the contents of the fenced code block as input. The second function (csv2html) gets the output of the first function as input.

The output of the last function in the pipeline is used as the content when generating the `output_markdown` and ultimately the resulting `html`

## Built in functions:

### include()

`include` takes a single parameter, a url. It downloads this url and outputs the result.

### csv2html()

`csv2html` takes no parameters, but expects valid CSV as input. It creates an HTML table from the given CSV.

### pretty_json()

`pretty_json` takes no parameters, but expects valid JSON as input. It formats the JSON nicely using Ruby's `JSON.pretty_generate` and outputs a fenced code block with the language specified as `json`.

### register()

Coming soon. Will register a variable.

### variable()

Coming soon. Will produce contents of a variable.

### hidden()

Coming soon. Will simply hide the given input.

## Extendable



## Installation

Add this line to your application's Gemfile:

    gem 'markdownplus'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install markdownplus

# Syntax

## Include external files

Use a fenced code block:

```markdown
  ```include('https://gist.githubusercontent.com/cpetersen/b5a473ddf0b796cd9502/raw/e140bdc32ff2f6a600e357c2575220c0312a88ee/fake.csv'),csv()
  ```
```
