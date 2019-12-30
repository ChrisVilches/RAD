require 'rails_helper'

RSpec.describe User, type: :model do

  it "can join companies" do
    c1 = create(:company)
    c2 = create(:company)
    u1 = create(:user)
    u2 = create(:user)

    c1.users << u1
    c2.users << u1
    u2.companies << c2

    expect(c1.users.length).to eq 1
    expect(c2.users.length).to eq 2

    expect(u1.companies.length).to eq 2
    expect(u2.companies.length).to eq 1
  end

  it "can have per-project permissions" do
    u = create :user
    c = create :company

    c.users << u
    p = create :project, company: c
    u.projects << p

    # Test in both directions
    expect(u.project_participations.length).to eq 1
    expect(u.project_participations.first).to be_a ProjectParticipation
    expect(u.projects.length).to eq 1
    expect(u.projects.first).to be_a Project

    expect(p.project_participations.length).to eq 1
    expect(p.project_participations.first).to be_a ProjectParticipation
    expect(p.users.length).to eq 1
    expect(p.users.first).to be_a User

    u.project_participations.first.develop_permission = true

    expect(u.project_participations.first.execution_permission).to be false # Default
    expect(u.project_participations.first.develop_permission).to be true
    expect(u.project_participations.first.publish_permission).to be false # Default

  end
end
