require "rails_helper"

RSpec.describe Container do
  it "can contain elements correctly" do
    c = create(:container)

    text_input = build :text_input
    numeric_input = build :numeric_input

    c.elements << build(:element, elementable: text_input, position: 0)
    c.elements << build(:element, elementable: numeric_input, position: 1)
    c.save!
    expect(c.elements.count).to eq 2
    expect(c.elements[0].elementable).to eq text_input
    expect(c.elements[1].elementable).to eq numeric_input
  end

  it "elements are saved whenever the container is saved (using build instead of create for building objects)" do
    c = build(:container)
    c.elements << build(:element, elementable: build(:numeric_input), position: 0)
    c.elements << build(:element, elementable: build(:text_input), position: 1)
    c.elements << build(:element, elementable: build(:text_input), position: 2)

    expect(c).to be_valid

    expect { c.save! }
    .to change { Container.count }.by(1)
    .and change { Element.count }.by(3)
    .and change { NumericInput.count }.by(1)
    .and change { TextInput.count }.by(2)
  end

  describe "nested containers" do

    let(:main_container) {
      # First layer
      c0 = build(:container)

      # Second layer
      c1 = build(:container)
      c2 = build(:container)

      # Third layer
      c3 = build(:container)

      # Fill third layer with elements
      c3.elements << build(:element, elementable: build(:numeric_input), position: 0)

      # Fill second layer with elements
      c1.elements << build(:element, elementable: build(:numeric_input), position: 0)
      c1.elements << build(:element, elementable: build(:option_input), position: 1)
      c1.elements << build(:element, elementable: build(:text_input), position: 2)
      c2.elements << build(:element, elementable: c3, position: 0)
      c2.elements << build(:element, elementable: build(:numeric_input), position: 1)

      c0.elements << build(:element, elementable: build(:numeric_input), position: 0)
      c0.elements << build(:element, elementable: c1, position: 1)
      c0.elements << build(:element, elementable: build(:text_input), position: 2)
      c0.elements << build(:element, elementable: c2, position: 3)
      c0
    }

    let(:wrong_nested_container_input_with_wrong_params) {
      c0 = build(:container)
      c1 = build(:container)
      c1.elements << build(:element, elementable: build(:numeric_input, min: 6, max: 2), position: 0)
      c0.elements << build(:element, position: 0)
      c0.elements << build(:element, elementable: c1, position: 1)
      c0
    }

    let(:wrong_nested_container_inputs_wrong_order) {
      c0 = build(:container)
      c1 = build(:container)
      c1.elements << build(:element, position: 0)
      c1.elements << build(:element, position: 2)
      c0.elements << build(:element, position: 0)
      c0.elements << build(:element, elementable: c1, position: 1)
      c0
    }

    it "saves recursively every element and nested container when saving the root container" do
      expect(main_container.id).to be_nil
      expect { main_container.save! }
      .to change { Container.count }.by(4)
      .and change { Element.count }.by(10)
      .and change { NumericInput.count }.by(4)
      .and change { OptionInput.count }.by(1)
      .and change { TextInput.count }.by(2)
    end

    it "validates recursively" do
      expect(main_container).to be_valid
      expect(wrong_nested_container_input_with_wrong_params).to_not be_valid
      expect(wrong_nested_container_inputs_wrong_order).to_not be_valid
    end

    it "has an API that allows every element and nested container (and its elements) to be get easily" do
      expect(main_container.elements.length).to eq 4
      expect(main_container.element_list[0]).to be_a NumericInput
      expect(main_container.element_list[1]).to be_a Container
      expect(main_container.element_list[2]).to be_a TextInput
      expect(main_container.element_list[3]).to be_a Container

      expect(main_container.element_list[1].elements.length).to eq 3
      expect(main_container.element_list[3].elements.length).to eq 2

      expect(main_container.element_list[1].element_list[0]).to be_a NumericInput
      expect(main_container.element_list[1].element_list[1]).to be_a OptionInput
      expect(main_container.element_list[1].element_list[2]).to be_a TextInput

      expect(main_container.element_list[3].element_list[0]).to be_a Container
      expect(main_container.element_list[3].element_list[1]).to be_a NumericInput

      expect(main_container.element_list[3].element_list[0].elements.length).to eq 1
      expect(main_container.element_list[3].element_list[0].element_list.first).to be_a NumericInput
    end

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
    c = create(:container)

    text_input = build :text_input
    numeric_input = build :numeric_input

    c.elements << build(:element, elementable: build(:text_input), position: 0)
    c.elements << build(:element, elementable: build(:text_input), position: 1)
    c.elements << build(:element, elementable: build(:numeric_input), position: 2)
    c.save!

    expect(c.element_list.length).to be 3
    expect(c.element_list[0]).to be_a TextInput
    expect(c.element_list[1]).to be_a TextInput
    expect(c.element_list[2]).to be_a NumericInput
  end

  it "arranges position indexes correctly when saving the container (even if positions are set as nil at first)" do

    c = create(:container)

    el0 = build(:element, position: nil)
    el1 = build(:element, position: nil)
    el2 = build(:element, position: nil)

    c.elements << el0
    c.elements << el1
    c.elements << el2
    c.save!

    expect(el0.id).to_not be_nil
    expect(el1.id).to_not be_nil
    expect(el2.id).to_not be_nil

    expect(el0.position).to eq 0
    expect(el1.position).to eq 1
    expect(el2.position).to eq 2
  end


  it "validates that element order is correct (correct)" do
    container = create(:container)

    container.elements << build(:element, position: 0)
    container.elements << build(:element, position: 1)
    container.elements << build(:element, position: 2)
    container.elements << build(:element, position: 3)
    expect(container).to be_valid
  end

  it "validates that element order is correct (incorrect - missing position - invalid object)" do
    container = create(:container)

    container.elements << build(:element, position: 0)
    container.elements << build(:element, position: 1)
    container.elements << build(:element, position: 3)
    expect(container).to_not be_valid

    container.elements << build(:element, position: 2)
    expect(container).to be_valid
  end

  it "validates that element order is correct (incorrect - repeated position - database error)" do
    container = create(:container)

    container.elements << build(:element, position: 0)
    container.elements << build(:element, position: 1)
    container.elements << build(:element, position: 2)
    expect{
      container.elements << build(:element, position: 2)
    }.to raise_error ActiveRecord::RecordNotUnique
  end

  pending "A container cannot have inputs with the same variable name twice in it, or nested containers but two different (not related/nested containers, but from the same view, can have the same variable name)"

end
