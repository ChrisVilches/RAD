require "rails_helper"

RSpec.describe "TextInput" do

  it "factory bot definition is correct" do
    expect(build(:text_input)).to be_valid
  end

  it "tells correctly when a string is multiline or not" do
    expect(TextInput.is_multiline?("aaa\na")).to be true
    expect(TextInput.is_multiline?("\naaa\na")).to be true
    expect(TextInput.is_multiline?("\n")).to be true
    expect(TextInput.is_multiline?("\n\n\n\n\n\n")).to be true
    expect(TextInput.is_multiline?("a")).to be false
    expect(TextInput.is_multiline?("")).to be false
    expect(TextInput.is_multiline?("aaaaa aaa a a a aaaaaa")).to be false
  end

  it "validates range correctly" do
    expect(build(:text_input, min: -1, max: nil)).to_not be_valid
    expect(build(:text_input, min: 0, max: nil, required: false)).to be_valid
    expect(build(:text_input, min: 0, max: nil, required: true)).to be_valid
    expect(build(:text_input, min: 1, max: nil, required: true)).to be_valid
    expect(build(:text_input, min: 2, max: 1, required: true)).to_not be_valid
    expect(build(:text_input, min: 1, max: 2, required: true)).to be_valid
    expect(build(:text_input, min: nil, max: 0, required: false)).to_not be_valid
    expect(build(:text_input, min: nil, max: 1, required: false)).to be_valid
    expect(build(:text_input, min: nil, max: 0, required: true)).to_not be_valid
    expect(build(:text_input, min: nil, max: 1, required: true)).to be_valid
  end


  describe "validation against user value" do


    it "validates correctly, vanilla configuration" do
      txt = create :text_input
      expect(txt.validate_input_value("")).to be true
    end

    it "validates correctly for various ranges" do
      expect(build(:text_input, min: 0, max: 1, required: false).validate_input_value("")).to be true
      expect(build(:text_input, min: 0, max: 1, required: true).validate_input_value("")).to be false

      expect(build(:text_input, min: 0, max: 1, required: false).validate_input_value(" ")).to be true
      expect(build(:text_input, min: 0, max: 1, required: true).validate_input_value(" ")).to be false

      expect(build(:text_input, min: 0, max: 1, required: true).validate_input_value("a")).to be true
      expect(build(:text_input, min: 0, max: 1, required: true).validate_input_value("aa")).to be false

      # Ignore spaces at both sides
      expect(build(:text_input, min: 0, max: 2).validate_input_value("  aaa   ")).to be false
      expect(build(:text_input, min: 0, max: 3).validate_input_value("  aaa   ")).to be true
    end

    it "validates regex correctly (one ore more digits)" do

      # Correct values (not required, so empty string becomes valid)
      ["", "1", "111", " 22 ", " 333", "123213   ", "1231231231413424234235454543"].each do |n|
        expect(build(:text_input, :one_or_more_digits).validate_input_value(n)).to be true
      end

      # Incorrect values
      ["a", "22\n3", "33x3", "123213 3", "4 1231231231413424234235454543"].each do |n|
        expect(build(:text_input, :one_or_more_digits).validate_input_value(n)).to be false
      end
    end

    it "validates correctly against the multiline flag. Newline at both sides is stripped" do
      # The following cases have newline that gets stripped
      expect(build(:text_input, multiline: true).validate_input_value("aa\n")).to be true
      expect(build(:text_input, multiline: false).validate_input_value("aa\n")).to be true
      expect(build(:text_input, multiline: true).validate_input_value("\naa\n")).to be true
      expect(build(:text_input, multiline: false).validate_input_value("\n\naa\n")).to be true

      expect(build(:text_input, multiline: true).validate_input_value("a\na\n")).to be true
      expect(build(:text_input, multiline: false).validate_input_value("a\na\n")).to be false
      expect(build(:text_input, multiline: true).validate_input_value("\na\naa\na\na\n")).to be true
      expect(build(:text_input, multiline: false).validate_input_value("\na\naa\n\n\n\n\na\na\n")).to be false
    end

    it "raises an error if the input configuration itself is incorrect when testing an input value against it" do
      expect {
        txt = create(:text_input, regex: "(") # This is invalid
        txt.validate_input_value("aa")
      }.to raise_error ActiveRecord::RecordInvalid
    end

    it "validates correctly for required/not required cases" do
      create(:text_input, required: true)
      expect(build(:text_input, required: true).validate_input_value(nil)).to be false
      expect(build(:text_input, required: false).validate_input_value(nil)).to be true
    end

    it "validates correctly for inputs that are not string" do
      expect(build(:text_input).validate_input_value("3434")).to be true
      expect(build(:text_input).validate_input_value("")).to be true
      expect(build(:text_input).validate_input_value(3434)).to be false
      expect(build(:text_input).validate_input_value(false)).to be false
    end
  end
end
