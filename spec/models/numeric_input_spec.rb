require "rails_helper"

RSpec.describe NumericInput do

  it "factory bot definition is correct" do
    expect(build(:numeric_input)).to be_valid
  end

  it "verifies that range is correct" do
    expect(build(:numeric_input, min: 1, max: 5)).to be_valid
    expect(build(:numeric_input, min: nil, max: 5)).to be_valid
    expect(build(:numeric_input, min: 1, max: nil)).to be_valid
    expect(build(:numeric_input, min: 5, max: 5)).to be_valid
  end

  it "invalids ranges that are incorrect" do
    expect(build(:numeric_input, min: 8, max: 5)).to_not be_valid
    expect(build(:numeric_input, min: 5, max: 2)).to_not be_valid
    expect(build(:numeric_input, min: 5, max: 4.999)).to_not be_valid
    expect(build(:numeric_input, min: 10, max: -10)).to_not be_valid
  end

  it "validates number set (type) correctly" do
    expect(build(:numeric_input, number_set: NumericInput::number_sets[:decimal])).to be_valid
    expect(build(:numeric_input, number_set: NumericInput::number_sets[:integer])).to be_valid
    expect(build(:numeric_input, number_set: NumericInput::number_sets[:binary])).to be_valid
    expect(build(:numeric_input, number_set: nil)).to_not be_valid
    expect{ create(:numeric_input, number_set: -2) }.to raise_error ArgumentError
    expect{ create(:numeric_input, number_set: -1) }.to raise_error ArgumentError
    expect{ create(:numeric_input, number_set: 0) }.to_not raise_error
    expect{ create(:numeric_input, number_set: 1) }.to_not raise_error
    expect{ create(:numeric_input, number_set: 2) }.to_not raise_error
    expect{ create(:numeric_input, number_set: 3) }.to raise_error ArgumentError
    expect{ create(:numeric_input, number_set: 4) }.to raise_error ArgumentError
  end

  it "excluded values are always unique and sorted" do
    num = create(:numeric_input)

    num.excluded_values << 4
    num.save!
    expect(num.excluded_values).to eq [4]

    num.excluded_values << 4
    num.save!
    expect(num.excluded_values).to eq [4]

    num.excluded_values << 2
    num.save!
    expect(num.excluded_values).to eq [2, 4]
  end

  describe "validation against user value" do
    it "validates correctly for decimal" do
      expect(build(:numeric_input, :decimal, min: 1, max: 4, excluded_values: [2, 3, 4]).validate_input_value(4)).to be false
      expect(build(:numeric_input, :decimal, min: 1, max: 4, excluded_values: [2, 3, 4]).validate_input_value(2)).to be false
      expect(build(:numeric_input, :decimal, min: 1, max: 4, excluded_values: [2, 3, 4]).validate_input_value(3.0)).to be false
      expect(build(:numeric_input, :decimal, min: 1, max: 4, excluded_values: [2, 3, 4]).validate_input_value(3.5)).to be true
      expect(build(:numeric_input, :decimal, min: 1, max: 4, excluded_values: [2, 3, 4]).validate_input_value(1000)).to be false
      expect(build(:numeric_input, :decimal, min: 1, max: nil, excluded_values: [2, 3, 4]).validate_input_value(1000)).to be true
    end

    it "validates correctly for integer" do
      expect(build(:numeric_input, :integer, min: 1, max: 4, excluded_values: [2, 3, 4]).validate_input_value(4)).to be false
      expect(build(:numeric_input, :integer, min: 1, max: 4, excluded_values: [2, 3, 4]).validate_input_value(4.5)).to be false
      expect(build(:numeric_input, :integer, min: 1, max: 4, excluded_values: [2, 3, 4]).validate_input_value(2)).to be false
      expect(build(:numeric_input, :integer, min: 1, max: 4, excluded_values: [2, 3, 4]).validate_input_value(3.0)).to be false
      expect(build(:numeric_input, :integer, min: 1, max: 4, excluded_values: [2, 3, 4]).validate_input_value(3.5)).to be false
      expect(build(:numeric_input, :integer, min: 1, max: 4, excluded_values: [2, 3, 4]).validate_input_value(1000)).to be false
      expect(build(:numeric_input, :integer, min: 1, max: nil, excluded_values: [2, 3, 4]).validate_input_value(1000)).to be true
      expect(build(:numeric_input, :integer, min: nil, max: 4545, excluded_values: [2, 3, 4]).validate_input_value(-1000)).to be true
      expect(build(:numeric_input, :integer, min: 1, max: 10).validate_input_value(5.5)).to be false
    end

    it "validates correctly for binary" do
      expect(build(:numeric_input, :binary).validate_input_value(0)).to be true
      expect(build(:numeric_input, :binary).validate_input_value(1)).to be true
      expect(build(:numeric_input, :binary).validate_input_value(2)).to be false
      expect(build(:numeric_input, :binary, excluded_values: [0]).validate_input_value(0)).to be true
    end

    it "raises an error if the input configuration itself is incorrect when testing an input value against it" do
      expect {
        num = create(:numeric_input, number_set: nil) # This is invalid
        num.validate_input_value(3)
      }.to raise_error ActiveRecord::RecordInvalid
    end

    it "validates correctly for required/not required cases" do
      expect(build(:numeric_input, :decimal, required: true).validate_input_value(nil)).to be false
      expect(build(:numeric_input, :decimal, required: false).validate_input_value(nil)).to be true
    end

    it "validates correctly for inputs that are not numeric" do
      expect(build(:numeric_input, :decimal).validate_input_value("3434")).to be false
      expect(build(:numeric_input, :decimal).validate_input_value(true)).to be false
      expect(build(:numeric_input, :decimal).validate_input_value(3434)).to be true
    end
  end


  describe "preprocessing before validations" do

    it "preprocesses only when the object is persisted to the database or an input value is tested against it" do
      num = build(:numeric_input, :integer, min: 1.2, max: 6.7, excluded_values: [1.2, 1.6, 2.6, 2.9, 0.5])
      expect(num.min).to be 1.2
      expect(num.max).to be 6.7
      expect(num.excluded_values).to eq [1.2, 1.6, 2.6, 2.9, 0.5]
      num.validate_input_value(3) # This method automatically validates, and therefore runs all before_validation, etc.
      expect(num.min).to eq 1
      expect(num.max).to eq 6
      expect(num.excluded_values).to eq [0, 1, 2]
    end

    it "processes numbers correctly when it's decimal (doesn't change)" do
      num = create(:numeric_input, :decimal, min: 1.2, max: 4.6, excluded_values: [1, 2, 3.4, 3.2, 5])
      expect(num.min).to eq 1.2
      expect(num.max).to eq 4.6
      expect(num.excluded_values).to eq [1, 2, 3.2, 3.4, 5]
    end

    it "processes numbers correctly when it's integer (also process of excluded values is done POST converting to integers)" do
      num = create(:numeric_input, :integer, min: -5.2, max: 4.6, excluded_values: [1, 2, 3.4, 3.2, 5])
      expect(num.min).to eq -5
      expect(num.max).to eq 4
      expect(num.excluded_values).to eq [1, 2, 3, 5]
    end

    it "processes numbers correctly when it's integer (only if the numbers are not null)" do
      num = create(:numeric_input, :integer, min: -5.2, max: nil)
      expect(num.min).to eq -5
      expect(num.max).to eq nil
    end

    it "processes numbers correctly when it's binary" do
      num = create(:numeric_input, :binary, min: -5.2, max: 4.6, excluded_values: [1, 2, 3.4, 3.2, 5])
      expect(num.min).to eq nil
      expect(num.max).to eq nil
      expect(num.excluded_values).to eq []
    end

  end

end
