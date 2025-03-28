# frozen_string_literal: true

require "rails_helper"

describe "Visit a proposal", perform_enqueued: true do # rubocop:disable RSpec/DescribeClass
  let!(:proposal) { create(:proposal, component:) }
  let(:organization) { component.organization }
  let(:component) { create(:proposal_component) }

  before do
    switch_to_host(organization.host)
    page.visit main_component_path(component)
    click_on proposal.title["en"]
  end

  it "allows viewing a single proposal" do
    expect(page).to have_content(proposal.title["en"])
    expect(page).to have_content(strip_tags(proposal.body["en"]).strip)
  end
end
