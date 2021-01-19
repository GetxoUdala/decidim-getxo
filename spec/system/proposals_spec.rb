# frozen_string_literal: true

require "rails_helper"

describe "Visit a proposal", type: :system, perform_enqueued: true do
  let!(:proposal) { create :proposal, component: component }
  let(:organization) { component.organization }
  let(:component) { create(:proposal_component) }

  before do
    switch_to_host(organization.host)
    page.visit main_component_path(component)
    click_link proposal.title["en"]
  end

  it "allows viewing a single proposal" do
    expect(page).to have_content(proposal.title["en"])
    expect(page).to have_content(strip_tags(proposal.body["en"]).strip)
  end
end
