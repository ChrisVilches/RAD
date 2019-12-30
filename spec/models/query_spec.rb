require "rails_helper"

RSpec.describe Query, type: :model do

  it "factory bot definition is correct" do
    expect(build(:query)).to be_valid
    expect(build(:query, :with_form_container)).to be_valid
  end

  it "has API to get form container associated to the query" do
    query = build(:view, :with_form_container)
    expect(query).to respond_to :container
    expect(query).to_not respond_to :global_form_containers
    expect(query).to_not respond_to :main_form_container
    expect(query).to_not respond_to :form_container
    expect(query).to_not respond_to :containers
    expect(query.container).to be_a Container

    # Container works as always
    container = query.container
    expect(container).to respond_to :element_list
  end

  pending "doesn't create a new revision if the code saved is the same as the latest revision"

end
