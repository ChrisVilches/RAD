require "rails_helper"

RSpec.describe View, type: :model do

  it "factory bot definition is correct" do
    expect(build(:view)).to be_valid
    expect(build(:view, :with_form_container)).to be_valid
  end

  it "has API to get main form container associated to the view" do
    view = build(:view, :with_form_container)
    expect(view).to respond_to :container
    expect(view).to_not respond_to :global_form_containers
    expect(view).to_not respond_to :main_form_container # old name
    expect(view).to_not respond_to :global_form_container # old name
    expect(view).to_not respond_to :containers
    expect(view.container).to be_a Container

    # Container works as always
    container = view.container
    expect(container).to respond_to :element_list
  end

  pending "empty containers are excluded from the view.
  In other words, containers that are leaf in the DOM tree are excluded,
  but I have to determine what happens when the view main container is empty
  (it's a different case)"

end
