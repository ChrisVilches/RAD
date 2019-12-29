require "rails_helper"

RSpec.describe OptionInput do

  it "factory bot definition is correct" do
    expect(build(:option_input)).to be_valid
  end

  it "validates option structure (factorybot traits)" do
    expect(build(:option_input, :colors)).to be_valid
    expect(build(:option_input, :device_types)).to be_valid
    expect(build(:option_input, :numbers)).to be_valid
  end

  it "validates option structure (custom)" do
    expect(build(:option_input, options: [{label: "a", value: 4}, {label: "b", value: 5.6}, {label: "c", value: "aaa"}])).to be_valid
  end

  it "validates option structure (options with empty value or label)" do
    expect(build(:option_input, options: [{label: "a", value: ""}])).to_not be_valid
    expect(build(:option_input, options: [{label: "", value: 56}])).to_not be_valid
  end

  it "validates option structure (value or label with wrong type)" do
    expect(build(:option_input, options: [{label: nil, value: ""}])).to_not be_valid
    expect(build(:option_input, options: [{label: "a", value: nil}])).to_not be_valid
    expect(build(:option_input, options: [{label: "a", value: []}])).to_not be_valid
    expect(build(:option_input, options: [{label: "a", value: {a: 5}}])).to_not be_valid
  end

  it "validates option structure (value or label that are repeated)" do
    expect(build(:option_input, options: [{label: "a", value: 44}, {label: "a", value: 66}])).to_not be_valid
    expect(build(:option_input, options: [{label: "a", value: 44}, {label: "b", value: 44}])).to_not be_valid
    expect(build(:option_input, options: [{label: " a", value: 44}, {label: "a     ", value: 66}])).to_not be_valid
    expect(build(:option_input, options: [{label: "a", value: "x"}, {label: "b", value: "     x   "}])).to_not be_valid
  end

  it "is invalid if options array is empty" do
    expect(build(:option_input, options: [])).to_not be_valid
  end

  it "option inputs have their fields stripped after validation" do
    opt = build(:option_input, options: [{label: "a", value: " b"}, {label: "c  ", value: " d  "}])
    opt.validate!
    expect(opt.options[0]).to eq({"label" => "a", "value" => "b"})
    expect(opt.options[1]).to eq({"label" => "c", "value" => "d"})
  end

  describe "validate against input" do

    let(:numbers) {
      build(:option_input, :radio, options: [
        { label: "zero", value: 0 },
        { label: "one", value: 1 },
        { label: "two", value: 2 },
        { label: "three", value: 3 },
        { label: "four", value: 4 },
        { label: "five", value: 5 }
      ])
    }

    it "validates wrong input type" do
      expect(numbers.validate_input_value(3)).to be true
      expect(numbers.validate_input_value("aa")).to be false
      expect(numbers.validate_input_value(true)).to be false
      expect(numbers.validate_input_value([1.1])).to be false
      expect(numbers.validate_input_value(3.4)).to be false
      expect(numbers.validate_input_value(["1"])).to be false
    end

    it "validates repeated inputs (radio)" do
      expect(numbers.validate_input_value([0, 0, 0, 0])).to be true
      expect(numbers.validate_input_value([0, 0, 0, 1])).to be false # Should be only one
    end

    it "validates repeated inputs (checkbox)" do
      numbers.component_type = OptionInput::component_types[:checkbox]
      expect(numbers.validate_input_value([0, 0, 0, 0])).to be true
      expect(numbers.validate_input_value([0, 0, 0, 1])).to be true
    end

    it "validates inputs out of range (radio)" do
      expect(numbers.validate_input_value([-1])).to_not be true
      expect(numbers.validate_input_value([0, 0])).to be true
      expect(numbers.validate_input_value([1, 1])).to be true
      expect(numbers.validate_input_value([2, 2])).to be true
      expect(numbers.validate_input_value([3, 3])).to be true
      expect(numbers.validate_input_value([4, 4])).to be true
      expect(numbers.validate_input_value([5, 5])).to be true
      expect(numbers.validate_input_value([6, 6])).to_not be true
    end

    it "validates inputs out of range (checkbox)" do
      numbers.component_type = OptionInput::component_types[:checkbox]
      expect(numbers.validate_input_value([-1])).to_not be true
      expect(numbers.validate_input_value([0, 1, 2, 3, 4])).to be true
      expect(numbers.validate_input_value([3, 4, 5])).to be true
      expect(numbers.validate_input_value([0, 5, 6])).to_not be true
    end


  end

end
