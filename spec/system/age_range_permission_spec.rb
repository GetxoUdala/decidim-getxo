# frozen_string_literal: true

require "rails_helper"

describe "Admin configures age-range permission", :js do # rubocop:disable RSpec/DescribeClass
  let(:organization) { create(:organization, available_authorizations: %w(census_authorization_handler)) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let!(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
  let!(:component) { create(:proposal_component, :with_likes_enabled, participatory_space: participatory_process) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit Decidim::EngineRouter.admin_proxy(participatory_process).edit_component_permissions_path(component_id: component.id)

    within ".like-permission" do
      find("input[type=checkbox][value='census_authorization_handler']").click
    end
  end

  it "saves a valid age range" do
    within ".like-permission" do
      fill_in "Minimum age", with: "18"
      fill_in "Maximum age", with: "65"
    end
    click_on "Submit"

    expect(page).to have_content("Permissions updated successfully")
    saved = component.reload.permissions.dig("like", "authorization_handlers", "census_authorization_handler", "options")
    expect(saved).to include("minimum_age" => "18", "maximum_age" => "65")
  end

  it "does not save when minimum is greater than maximum" do
    within ".like-permission" do
      fill_in "Minimum age", with: "65"
      fill_in "Maximum age", with: "18"
    end
    click_on "Submit"

    expect(page).to have_content("Maximum age: must be greater than or equal to 65")
    expect(component.reload.permissions).to be_blank
  end

  it "marks the minimum_age input as invalid when a negative value is typed" do
    within ".like-permission" do
      fill_in "Minimum age", with: "-5"
      fill_in "Maximum age", with: ""
    end

    expect(page).to have_css("input.is-invalid-input[name$='[minimum_age]']")
    expect(page).to have_css("label.is-invalid-label", text: "Minimum age")
  end

  it "marks the maximum_age input as invalid when a negative value is typed" do
    within ".like-permission" do
      fill_in "Maximum age", with: "-5"
      fill_in "Minimum age", with: ""
    end

    expect(page).to have_css("input.is-invalid-input[name$='[maximum_age]']")
    expect(page).to have_css("label.is-invalid-label", text: "Maximum age")
  end
end
