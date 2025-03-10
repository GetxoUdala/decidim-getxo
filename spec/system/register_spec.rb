# frozen_string_literal: true

require "rails_helper"

describe "Visit the register page" do # rubocop:disable RSpec/DescribeClass
  let!(:proposal) { create(:proposal, component:) }
  let(:organization) { component.organization }
  let(:component) { create(:proposal_component) }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
    click_on "Create an account"
  end

  it "allows viewing the register page" do
    expect(page).to have_content("Your name")
    expect(page).to have_content("Your email")
    expect(page).to have_content("Password")
    expect(page).to have_no_content("Nickname")
    expect(page).to have_no_content("Confirm your password")
  end
end
