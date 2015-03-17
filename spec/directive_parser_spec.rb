require 'markdownplus'
require 'spec_helper'

describe Markdownplus::DirectiveParser do
  context "a simple function with no params" do
    let(:value) { Markdownplus::DirectiveParser.parse("include()") }

    it "should return a TransformationLiteral" do
      expect(value.class).to eq(Markdownplus::Literals::TransformationLiteral)
    end

    it "should have a single function" do
      expect(value.functions.count).to eq(1)
    end

    it "should have a function named 'include'" do
      expect(value.functions.first.function_name).to eq("include")
    end

    it "should have no parameters" do
      expect(value.functions.first.function_parameters.count).to eq(0)
    end
  end

  context "a simple function with a single param" do
    let(:value) { Markdownplus::DirectiveParser.parse("include(test)") }

    it "should return a TransformationLiteral" do
      expect(value.class).to eq(Markdownplus::Literals::TransformationLiteral)
    end

    it "should have a single function" do
      expect(value.functions.count).to eq(1)
    end

    it "should have a function named 'include'" do
      expect(value.functions.first.function_name).to eq("include")
    end

    it "should have a single parameter" do
      expect(value.functions.first.function_parameters.count).to eq(1)
    end

    it "should have the parameter 'test'" do
      expect(value.functions.first.function_parameters.first.to_s).to eq("test")
    end
  end
  context "a simple function with a 3 params" do
    let(:value) { Markdownplus::DirectiveParser.parse("include(test, 'this is a test', nil)") }

    it "should return a TransformationLiteral" do
      expect(value.class).to eq(Markdownplus::Literals::TransformationLiteral)
    end

    it "should have a single function" do
      expect(value.functions.count).to eq(1)
    end

    it "should have a function named 'include'" do
      expect(value.functions.first.function_name).to eq("include")
    end

    it "should have 3 parameters" do
      expect(value.functions.first.function_parameters.count).to eq(3)
    end

    it "the first parameter should be correct" do
      expect(value.functions.first.function_parameters[0].class).to eq(Markdownplus::Literals::TokenLiteral)
      expect(value.functions.first.function_parameters[0].to_s).to eq("test")
    end

    it "the second parameter should be correct" do
      expect(value.functions.first.function_parameters[1].class).to eq(Markdownplus::Literals::StringLiteral)
      expect(value.functions.first.function_parameters[1].to_s).to eq("this is a test")
    end

    it "the third parameter should be correct" do
      expect(value.functions.first.function_parameters[2].class).to eq(Markdownplus::Literals::TokenLiteral)
      expect(value.functions.first.function_parameters[2].to_s).to eq("nil")
    end
  end

  context "a series of two functions" do
    let(:value) { Markdownplus::DirectiveParser.parse("include(), execute()") }

    it "should return a TransformationLiteral" do
      expect(value.class).to eq(Markdownplus::Literals::TransformationLiteral)
    end

    it "should have 2 functions" do
      pending "lists of functions don't work yet"
      expect(value.functions.count).to eq(2)
    end

    context "the first function" do
      let(:function) { value.functions[0] }

      it "should be 'include'" do
        expect(function.function_name).to eq("include")
      end

      it "should have no parameters" do
        expect(function.function_parameters.count).to eq(0)
      end
    end

    context "the second function" do
      let(:function) { value.functions[1] }

      it "should be 'include'" do
        pending "lists of functions don't work yet"
        expect(function.function_name).to eq("execute")
      end

      it "should have no parameters" do
        pending "lists of functions don't work yet"
        expect(function.function_parameters.count).to eq(0)
      end
    end
  end

  context "a function with a nested function" do
    let(:value) { Markdownplus::DirectiveParser.parse("include(test, execute('nested test'))") }

    it "should return a TransformationLiteral" do
      expect(value.class).to eq(Markdownplus::Literals::TransformationLiteral)
    end

    it "should have a single function" do
      expect(value.functions.count).to eq(1)
    end

    it "should have a function named 'include'" do
      expect(value.functions.first.function_name).to eq("include")
    end

    it "should have 2 parameters" do
      expect(value.functions.first.function_parameters.count).to eq(2)
    end

    context "the second function parameter" do
      let(:param) { value.functions.first.function_parameters[1] }

      it "should be a functionLiteral" do
        expect(param.class).to eq(Markdownplus::Literals::FunctionLiteral)
      end

      it "should be a function named 'execute'" do
        expect(param.function_name).to eq("execute")
      end
    end
  end
end
