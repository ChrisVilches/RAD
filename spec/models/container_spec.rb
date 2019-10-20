require "rails_helper"

RSpec.describe "Container" do
  it "can contain elements correctly" do
    c = Container.new

    text_input = TextInput.new
    numeric_input = NumericInput.new

    c.elements << Element.new(elementable: text_input)
    c.elements << Element.new(elementable: numeric_input)
    c.save!
    expect(c.elements.count).to eq 2
    expect(c.elements[0].elementable).to eq text_input
    expect(c.elements[1].elementable).to eq numeric_input
  end

  it "doesn't allow to add elements without a correct elementable" do
    c = Container.new
    c.elements << Element.new
    expect {
      c.save!
    }.to raise_error ActiveRecord::RecordInvalid

    expect(c).to_not be_valid
  end

  it "has a method that returns list of Element" do
    c = Container.new

    text_input = TextInput.new
    numeric_input = NumericInput.new

    c.elements << Element.new(elementable: text_input)
    c.elements << Element.new(elementable: numeric_input)
    c.save!

    expect(c.element_list.length).to be 2
    expect(c.element_list[0]).to be_a TextInput
    expect(c.element_list[1]).to be_a NumericInput
  end
end
