# frozen_string_literal: true

require "rails_helper"

describe "Visit the register page", type: :system do
  let!(:proposal) { create :proposal, component: component }
  let(:organization) { component.organization }
  let(:component) { create(:proposal_component) }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
    click_link "Sign Up"
  end

  it "allows viewing the register page" do
    expect(page).to have_content("Your name")
    expect(page).to have_content("Your email")
    expect(page).to have_content("Password")
    expect(page).not_to have_content("Nickname")
    expect(page).not_to have_content("Confirm your password")
  end
end
