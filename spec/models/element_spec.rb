require "rails_helper"

RSpec.describe "Element" do
  it "verifies that all element classes have shared methods" do

    expect(build(:numeric_input).methods).to include (:updated_at_previous_change)
    expect(TextInput.new.methods).to include (:updated_at_previous_change)

  end
end
