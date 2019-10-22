require "rails_helper"

RSpec.describe "Element" do

  it "factory bot definition is correct" do
    element = build(:element)
    expect(element).to be_valid
    expect(element.elementable).to be_kind_of NumericInput
  end

  it "element is not validated immediately when using build (FactoryBot)" do
    element = nil
    num = build(:numeric_input)
    expect(num.id).to be nil
    expect{ element = build(:element, elementable: num) }.to_not raise_error
    expect(element.elementable_id).to be nil

    element.save!
    expect(num.id).to_not be nil # ID for numerical input is generated
    expect(element.elementable_id).to_not be nil # ID generated as well
  end

  it "database composite key is unique" do
    container = create(:container)

    create(:element, container: container, position: 0)

    expect {
      create(:element, container: container, position: 0)
    }.to raise_error ActiveRecord::RecordNotUnique

    create(:element, container: container, position: 1)
  end

end
