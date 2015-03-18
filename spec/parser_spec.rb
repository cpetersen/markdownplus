require 'markdownplus'
require 'spec_helper'

describe Markdownplus::Parser do
  context "a simple file" do
    let(:file) { File.read(File.join(File.dirname(__FILE__), "..", "spec", "fixtures", "simple.mdp")) }

    it "should read the file" do
      expect(file).not_to be_empty
    end

    context "the parser" do
      let(:parser) { Markdownplus::Parser.parse(file) }
      
      it "should have the correct number of lines" do
        expect(parser.lines.count).to eq(17)
      end

      it "should have the correct number of blocks" do
        expect(parser.blocks.count).to eq(8)
      end

      it "should have the correct number of code blocks" do
        expect(parser.code_blocks.count).to eq(4)
      end

      it "should have the correct number of executable blocks" do
        expect(parser.executable_blocks.count).to eq(2)
      end

      context "input_markdown input_markdown method" do
        let(:input_markdown) { parser.input_markdown }

        it "should match the contents of the original file" do
          expect(input_markdown).to eq(file)
        end
      end

      context "the first block" do
        let(:block) { parser.blocks.first }
        it "should be a text block" do
          expect(block.class).to eq(Markdownplus::TextBlock)
        end
      end

      context "the second block" do
        let(:block) { parser.blocks[1] }
        it "should be a code block" do
          expect(block.class).to eq(Markdownplus::CodeBlock)
        end

        it "should have no directives" do
          expect(block.directive).to eq("")
        end
      end

      context "the fourth block" do
        let(:block) { parser.blocks[3] }
        it "should be a code block" do
          expect(block.class).to eq(Markdownplus::CodeBlock)
        end

        it "should have the proper directives" do
          expect(block.directive).to eq("ruby")
        end
      end

      context "the sixth block" do
        let(:block) { parser.blocks[5] }
        it "should be a code block" do
          expect(block.class).to eq(Markdownplus::CodeBlock)
        end

        it "should have the proper directives" do
          expect(block.directive).to eq("include()")
        end

        it "should be an executable block" do
          expect(block).to be_executable
        end
      end

      context "the eighth block" do
        let(:block) { parser.blocks[7] }
        it "should be a code block" do
          expect(block.class).to eq(Markdownplus::CodeBlock)
        end

        it "should be an executable block" do
          expect(block).to be_executable
        end

        it "should have 2 functions" do
          expect(block.functions.size).to eq(2)
        end

        context "the first function" do
          let(:function) { block.functions[0] }

          it "should have the proper name" do
            expect(function.function_name).to eq("include")
          end
        end

        context "the second function" do
          let(:function) { block.functions[1] }

          it "should have the proper name" do
            expect(function.function_name).to eq("json")
          end
        end
      end
    end
  end

  context "directives" do
    let(:parser) {
      allow(Markdownplus::IncludeHandler).to receive(:cached).with("https://gist.githubusercontent.com/cpetersen/b5a473ddf0b796cd9502/raw/e140bdc32ff2f6a600e357c2575220c0312a88ee/fake.csv").and_return( File.read(File.join(File.dirname(__FILE__), "..", "spec", "fixtures", "fake.csv")) )
      allow(Markdownplus::IncludeHandler).to receive(:cached).with("https://gist.githubusercontent.com/cpetersen/c6571117df132443ac81/raw/e5ac97e8e0665a0e4014ebc85ecef214763a7729/fake.json").and_return( File.read(File.join(File.dirname(__FILE__), "..", "spec", "fixtures", "fake.json")) )
      allow(Markdownplus::IncludeHandler).to receive(:cached).with("https://gist.githubusercontent.com/cpetersen/4ac0ab5fb4d1fda22322/raw/3856ed58d5cdfd07800067fc9fb8fcbcfc631d65/bad_json.json").and_return( File.read(File.join(File.dirname(__FILE__), "..", "spec", "fixtures", "bad_json.json")) )

      parser = Markdownplus::Parser.parse(File.read(File.join(File.dirname(__FILE__), "..", "spec", "fixtures", "directives.mdp")))
      parser.execute
      parser
    }
    it "should have the right number of blocks" do
      expect(parser.blocks.count).to eq(14)
    end

    it "should have 2 warnings" do
      expect(parser.warnings.count).to eq(2)
    end

    it "should have 3 errors" do
      expect(parser.errors.count).to eq(3)
    end

    context "the second block" do
      let(:block) { parser.blocks[1] }

      it "should include the proper number of output lines" do
        expect(block.output_lines.count).to eq(21)
      end
    end

    context "the html" do
      let(:generated_html) { parser.html }
      let(:static_html) { File.read(File.join(File.dirname(__FILE__), "..", "spec", "fixtures", "directives.html")) }

      it "should match" do
        expect(generated_html).to eq(static_html)
      end
    end

    context "the sixth block" do
      let(:block) { parser.blocks[5] }

      it "should have an error" do
        expect(block.errors.count).to eq(1)
      end

      it "should have the missing url error" do
        expect(block.errors.first).to eq("No url given")
      end
    end

    context "the eighth block" do
      let(:block) { parser.blocks[7] }

      it "should have a warning" do
        expect(block.warnings.count).to eq(1)
      end

      it "should have input ignored warning" do
        expect(block.warnings.first).to eq("Include handler ignores input")
      end
    end

    context "the twelfth block" do
      let(:block) { parser.blocks[11] }

      it "should have 1 error" do
        expect(block.errors.count).to eq(1)
      end

      it "should have invalid json" do
        expect(block.errors.first).to eq("Invalid json")
      end
    end

    context "the fourteenth block" do
      let(:block) { parser.blocks[13] }

      it "should have an error" do
        expect(block.errors.count).to eq(1)
      end

      it "should have the missing url error" do
        expect(block.errors.first).to eq("No url given")
      end

      it "should have a warning" do
        expect(block.warnings.count).to eq(1)
      end

      it "should have input ignored warning" do
        expect(block.warnings.first).to eq("Include handler ignores input")
      end
    end
  end
end
