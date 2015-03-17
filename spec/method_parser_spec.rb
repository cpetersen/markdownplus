require 'markdownplus'
require 'spec_helper'

describe Markdownplus::MethodParser do
  context "a simple method with no params" do
    let(:value) { Markdownplus::MethodParser.parse("include()") }

    it "should return a TransformationLiteral" do
      expect(value.class).to eq(Markdownplus::Literals::TransformationLiteral)
    end

    it "should have a single method" do
      expect(value.methods.count).to eq(1)
    end

    it "should have a method named 'include'" do
      expect(value.methods.first.method_name).to eq("include")
    end

    it "should have no parameters" do
      expect(value.methods.first.method_parameters.count).to eq(0)
    end
  end

  context "a simple method with a single param" do
    let(:value) { Markdownplus::MethodParser.parse("include(test)") }

    it "should return a TransformationLiteral" do
      expect(value.class).to eq(Markdownplus::Literals::TransformationLiteral)
    end

    it "should have a single method" do
      expect(value.methods.count).to eq(1)
    end

    it "should have a method named 'include'" do
      expect(value.methods.first.method_name).to eq("include")
    end

    it "should have a single parameter" do
      expect(value.methods.first.method_parameters.count).to eq(1)
    end

    it "should have the parameter 'test'" do
      expect(value.methods.first.method_parameters.first.to_s).to eq("test")
    end
  end
  context "a simple method with a 3 params" do
    let(:value) { Markdownplus::MethodParser.parse("include(test, 'this is a test', nil)") }

    it "should return a TransformationLiteral" do
      expect(value.class).to eq(Markdownplus::Literals::TransformationLiteral)
    end

    it "should have a single method" do
      expect(value.methods.count).to eq(1)
    end

    it "should have a method named 'include'" do
      expect(value.methods.first.method_name).to eq("include")
    end

    it "should have 3 parameters" do
      expect(value.methods.first.method_parameters.count).to eq(3)
    end

    it "the first parameter should be correct" do
      expect(value.methods.first.method_parameters[0].class).to eq(Markdownplus::Literals::TokenLiteral)
      expect(value.methods.first.method_parameters[0].to_s).to eq("test")
    end

    it "the second parameter should be correct" do
      expect(value.methods.first.method_parameters[1].class).to eq(Markdownplus::Literals::StringLiteral)
      expect(value.methods.first.method_parameters[1].to_s).to eq("this is a test")
    end

    it "the third parameter should be correct" do
      expect(value.methods.first.method_parameters[2].class).to eq(Markdownplus::Literals::TokenLiteral)
      expect(value.methods.first.method_parameters[2].to_s).to eq("nil")
    end
  end

  context "a series of two methods" do
    let(:value) { Markdownplus::MethodParser.parse("include(), execute()") }

    it "should return a TransformationLiteral" do
      expect(value.class).to eq(Markdownplus::Literals::TransformationLiteral)
    end

    it "should have 2 methods" do
      pending "lists of methods don't work yet"
      expect(value.methods.count).to eq(2)
    end

    context "the first method" do
      let(:method) { value.methods[0] }

      it "should be 'include'" do
        expect(method.method_name).to eq("include")
      end

      it "should have no parameters" do
        expect(method.method_parameters.count).to eq(0)
      end
    end

    context "the second method" do
      let(:method) { value.methods[1] }

      it "should be 'include'" do
        pending "lists of methods don't work yet"
        expect(method.method_name).to eq("execute")
      end

      it "should have no parameters" do
        pending "lists of methods don't work yet"
        expect(method.method_parameters.count).to eq(0)
      end
    end
  end

  context "a method with a nested method" do
    let(:value) { Markdownplus::MethodParser.parse("include(test, execute('nested test'))") }

    it "should return a TransformationLiteral" do
      expect(value.class).to eq(Markdownplus::Literals::TransformationLiteral)
    end

    it "should have a single method" do
      expect(value.methods.count).to eq(1)
    end

    it "should have a method named 'include'" do
      expect(value.methods.first.method_name).to eq("include")
    end

    it "should have 2 parameters" do
      expect(value.methods.first.method_parameters.count).to eq(2)
    end

    context "the second method parameter" do
      let(:param) { value.methods.first.method_parameters[1] }

      it "should be a MethodLiteral" do
        expect(param.class).to eq(Markdownplus::Literals::MethodLiteral)
      end

      it "should be a method named 'execute'" do
        expect(param.method_name).to eq("execute")
      end
    end
  end
end
