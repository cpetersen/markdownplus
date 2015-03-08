require 'markdownplus'
require 'spec_helper'

describe Markdownplus::Parser do
  context "a simple file" do
    let(:file) { File.read(File.join(File.dirname(__FILE__), "..", "spec", "fixtures", "simple.md")) }

    it "should read the file" do
      expect(file).not_to be_empty
    end

    context "the parser" do
      let(:parser) { Markdownplus::Parser.parse(file) }
      
      it "should have the correct number of lines" do
        expect(parser.lines.count).to eq(21)
      end

      it "should have the correct number of blocks" do
        expect(parser.blocks.count).to eq(10)
      end

      it "should have the correct number of code blocks" do
        expect(parser.code_blocks.count).to eq(5)
      end

      it "should have the correct number of include blocks" do
        expect(parser.includable_blocks.count).to eq(2)
      end

      it "should have the correct number of execute blocks" do
        expect(parser.executable_blocks.count).to eq(1)
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
          expect(block.directives).to eq([])
        end
      end

      context "the fourth block" do
        let(:block) { parser.blocks[3] }
        it "should be a code block" do
          expect(block.class).to eq(Markdownplus::CodeBlock)
        end

        it "should have the proper directives" do
          expect(block.directives).to eq(["ruby"])
        end
      end

      context "the sixth block" do
        let(:block) { parser.blocks[5] }
        it "should be a code block" do
          expect(block.class).to eq(Markdownplus::CodeBlock)
        end

        it "should have the proper directives" do
          expect(block.directives).to eq(["include"])
        end

        it "should be an include block" do
          expect(block).to be_includable
        end
      end

      context "the eighth block" do
        let(:block) { parser.blocks[7] }
        it "should be a code block" do
          expect(block.class).to eq(Markdownplus::CodeBlock)
        end

        it "should have the proper directives" do
          expect(block.directives).to eq(["include", "json"])
        end

        it "should be an include block" do
          expect(block).to be_includable
        end
      end

      context "the tenth block" do
        let(:block) { parser.blocks[9] }
        it "should be a code block" do
          expect(block.class).to eq(Markdownplus::CodeBlock)
        end

        it "should have the proper directives" do
          expect(block.directives).to eq(["execute", "julia"])
        end

        it "should be an execute block" do
          expect(block).to be_executable
        end
      end
    end
  end

  context "include directives" do
    let(:parser) { 
      parser = Markdownplus::Parser.parse(File.read(File.join(File.dirname(__FILE__), "..", "spec", "fixtures", "include.md"))) 
      parser.include
      parser
    }
    it "should have the right number of blocks" do
      expect(parser.blocks.count).to eq(10)
    end
    context "the second block" do
      let(:block) { parser.blocks[1] }

      it "should include the proper number of lines" do
        expect(block.lines.count).to eq(21)
      end
    end

  end
end
