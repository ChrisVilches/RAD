require "rails_helper"

RSpec.describe Company do

  it "factory bot definition is correct" do
    expect(build(:company)).to be_valid

    # Urls are created unique.
    expect{
      create :company
      create :company
      create :company
    }.to_not raise_error
  end

  it "has a list of projects" do
    c = build :company
    p1 = build(:project)
    p2 = build(:project)
    c.projects << p1
    c.projects << p2

    expect(c.projects.length).to eq 2
    expect(p1.company).to be_a Company
  end

  it "has unique URL slugs" do
    create :company, url: "aaa"
    expect{
      create :company, url: "aaa"
    }.to raise_error ActiveRecord::RecordNotUnique
  end

  it "cannot have URL shorter than two characters (minimum is 2)" do
    expect(build :company, url: "aaa").to be_valid
    expect(build :company, url: "aa").to be_valid
    expect(build :company, url: "a").to_not be_valid
  end

  it "lowers case for urls" do
    expect(create(:company, url: "AaA").url).to eq "aaa"
    expect(create(:company, url: "BBB").url).to eq "bbb"

    expect{
      create :company, url: "aAa"
    }.to raise_error ActiveRecord::RecordNotUnique

  end

  it "can have users that joined" do
    c = create(:company)
    u1 = create(:user)
    u2 = create(:user)
    u3 = create(:user)

    c.users << u1
    c.users << u2
    c.users << u3

    expect(c.users.length).to eq 3
    expect(c.users.first).to be_a User

    expect(c.participations.length).to eq 3
    expect(c.participations.first).to be_a Participation
  end

  pending "validates url format and accepted characters"

end
