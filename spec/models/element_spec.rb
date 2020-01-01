require "rails_helper"

RSpec.describe Element, type: :model do

  it "factory bot definition is correct" do
    element = build(:element)
    expect(element).to be_valid
    expect(element.elementable).to be_kind_of NumericInput
  end

  it "is not validated immediately when using build (FactoryBot)" do
    element = nil
    num = build(:numeric_input)
    expect(num.id).to be nil
    expect{ element = build(:element, elementable: num) }.to_not raise_error
    expect(element.elementable_id).to be nil

    element.save!
    expect(num.id).to_not be nil # ID for numerical input is generated
    expect(element.elementable_id).to_not be nil # ID generated as well
  end


  it "ensures elements that have a Container elementable have optional label, but those that are not Containers must have a label" do

    num = build(:element, label: nil, elementable: build(:numeric_input))
    txt = build(:element, label: nil, elementable: build(:text_input))
    opt = build(:element, label: nil, elementable: build(:option_input))
    con = build(:element, label: nil, elementable: build(:container))

    expect(num).to_not be_valid
    expect(txt).to_not be_valid
    expect(opt).to_not be_valid
    expect(con).to be_valid

    num = build(:element, label: "", elementable: build(:numeric_input))
    txt = build(:element, label: "  ", elementable: build(:text_input))
    opt = build(:element, label: "", elementable: build(:option_input))
    con = build(:element, label: "", elementable: build(:container))

    expect(num).to_not be_valid
    expect(txt).to_not be_valid
    expect(opt).to_not be_valid
    expect(con).to be_valid

    num = build(:element, label: "a", elementable: build(:numeric_input))
    txt = build(:element, label: "b", elementable: build(:text_input))
    opt = build(:element, label: "c", elementable: build(:option_input))
    con = build(:element, label: "d", elementable: build(:container))

    expect(num).to be_valid
    expect(txt).to be_valid
    expect(opt).to be_valid
    expect(con).to be_valid

    con.save!
    con.reload
    expect(con.label).to eq "d" # Label is not required but it can be assigned.
  end


  pending "ensures that (non-container) elements can have description but not containers"

  it "database composite key is unique" do
    container = create(:container)

    create(:element, container: container, position: 0)

    expect {
      create(:element, container: container, position: 0)
    }.to raise_error ActiveRecord::RecordNotUnique

    create(:element, container: container, position: 1)
  end

  it "has elementable_type with class name (not Input, but a specific class name)" do
    expect(create(:element, elementable: build(:numeric_input)).elementable_type).to eq "NumericInput"
    expect(create(:element, elementable: build(:text_input)).elementable_type).to eq "TextInput"
    expect(create(:element, elementable: build(:option_input)).elementable_type).to eq "OptionInput"
    expect(create(:element, elementable: build(:container)).elementable_type).to eq "Container"
  end

  it "has a correct elementable_type value (only allowed values)" do
    create(:element, elementable: build(:project))
    pending "Should not be able to create element with a project (or other non allowed class) as elementable type"
    fail
  end

  it "has a correct, non-null and non-empty variable_name" do
    expect(build(:element, variable_name: nil)).to_not be_valid
    expect(build(:element, variable_name: "")).to_not be_valid
    expect(build(:element, variable_name: "a")).to be_valid
    expect(build(:element, variable_name: "aA")).to be_valid
    expect(build(:element, variable_name: "(a)")).to_not be_valid
    expect(build(:element, variable_name: "1234567890123456789")).to be_valid
    expect(build(:element, variable_name: "12345678901234567890")).to be_valid
    expect(build(:element, variable_name: "123456789012345678901")).to_not be_valid
    expect(build(:element, variable_name: "aaa$")).to_not be_valid
    expect(build(:element, variable_name: "aaa.bbb")).to_not be_valid
  end


end
