require "rails_helper"

RSpec.describe TextInput, type: :model do

  it "factory bot definition is correct" do
    expect(build(:text_input)).to be_valid
  end

  it "tells correctly when a string is multiline or not" do
    expect(TextInput.multiline?("aaa\na")).to be true
    expect(TextInput.multiline?("\naaa\na")).to be true
    expect(TextInput.multiline?("\n")).to be true
    expect(TextInput.multiline?("\n\n\n\n\n\n")).to be true
    expect(TextInput.multiline?("a")).to be false
    expect(TextInput.multiline?("")).to be false
    expect(TextInput.multiline?("aaaaa aaa a a a aaaaaa")).to be false
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
      expect(txt.input_value_errors("")).to be_empty
    end

    it "validates correctly for various ranges" do
      expect(build(:text_input, min: 0, max: 1, required: false).input_value_errors("")).to be_empty
      expect(build(:text_input, min: 0, max: 1, required: true).input_value_errors("")).to_not be_empty

      expect(build(:text_input, min: 0, max: 1, required: false).input_value_errors(" ")).to be_empty
      expect(build(:text_input, min: 0, max: 1, required: true).input_value_errors(" ")).to_not be_empty

      expect(build(:text_input, min: 0, max: 1, required: true).input_value_errors("a")).to be_empty
      expect(build(:text_input, min: 0, max: 1, required: true).input_value_errors("aa")).to_not be_empty

      # Ignore spaces at both sides
      expect(build(:text_input, min: 0, max: 2).input_value_errors("  aaa   ")).to_not be_empty
      expect(build(:text_input, min: 0, max: 3).input_value_errors("  aaa   ")).to be_empty
    end

    it "validates regex correctly (one ore more digits)" do

      # Correct values (not required, so empty string becomes valid)
      ["", "1", "111", " 22 ", " 333", "123213   ", "1231231231413424234235454543"].each do |n|
        expect(build(:text_input, :one_or_more_digits).input_value_errors(n)).to be_empty
      end

      # Incorrect values
      ["a", "22\n3", "33x3", "123213 3", "4 1231231231413424234235454543"].each do |n|
        expect(build(:text_input, :one_or_more_digits).input_value_errors(n)).to_not be_empty
      end
    end

    it "validates correctly against the multiline flag. Newline at both sides is stripped" do
      # The following cases have newline that gets stripped
      expect(build(:text_input, multiline: true).input_value_errors("aa\n")).to be_empty
      expect(build(:text_input, multiline: false).input_value_errors("aa\n")).to be_empty
      expect(build(:text_input, multiline: true).input_value_errors("\naa\n")).to be_empty
      expect(build(:text_input, multiline: false).input_value_errors("\n\naa\n")).to be_empty

      # These have newline characters in the middle
      expect(build(:text_input, multiline: true).input_value_errors("a\na\n")).to be_empty
      expect(build(:text_input, multiline: false).input_value_errors("a\na\n")).to_not be_empty
      expect(build(:text_input, multiline: true).input_value_errors("\na\naa\na\na\n")).to be_empty
      expect(build(:text_input, multiline: false).input_value_errors("\na\naa\n\n\n\n\na\na\n")).to_not be_empty
    end

    it "raises an error if the input configuration itself is incorrect when testing an input value against it" do
      expect {
        txt = create(:text_input, regex: "(") # This is invalid
        txt.input_value_errors("aa")
      }.to raise_error ActiveRecord::RecordInvalid
    end

    it "validates correctly for required/not required cases" do
      create(:text_input, required: true)
      expect(build(:text_input, required: true).input_value_errors(nil)).to_not be_empty
      expect(build(:text_input, required: false).input_value_errors(nil)).to be_empty
    end

    it "validates correctly for inputs that are not string" do
      expect(build(:text_input).input_value_errors("3434")).to be_empty
      expect(build(:text_input).input_value_errors("")).to be_empty
      expect(build(:text_input).input_value_errors(3434)).to_not be_empty
      expect(build(:text_input).input_value_errors(false)).to_not be_empty
    end
  end
end
