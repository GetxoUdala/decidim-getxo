# frozen_string_literal: true

require "rails_helper"
require "decidim/core/test/factories"
require "decidim/budgets/test/factories"

describe "Orders", type: :system do
  include_context "with a component"
  let(:manifest_name) { "budgets" }

  let(:organization) { create :organization, available_authorizations: %w(dummy_authorization_handler) }
  let!(:user) { create :user, :confirmed, organization: organization }
  let(:first_project) { projects.first }
  let(:last_project) { projects.last }

  let!(:component) do
    create(:budgets_component,
           :with_show_votes_enabled,
           manifest: manifest,
           participatory_space: participatory_process)
  end

  let(:budget) { create :budget, component: component, total_budget: 50_000_000 }

  context "when the user is logged in" do
    let!(:projects) { create_list(:project, 3, budget: budget, budget_amount: 25_000_000) }

    before do
      login_as user, scope: :user
    end

    context "when visiting budget" do
      before do
        page.visit Decidim::EngineRouter.main_proxy(component).budget_projects_path(budget)
      end

      it "Sets order of pick" do
        within "#project-#{first_project.id}-item" do
          page.find(".budget-list__action").click
        end

        expect(page).to have_selector("#project-#{first_project.id}-item .budget-list__action", text: projects.count)
        expect(page).to have_selector("#project-#{first_project.id}-item .project-votes", text: "1")
        expect(page).to have_selector("#project-#{last_project.id}-item .budget-list__action", text: "")
        expect(page).to have_selector("#project-#{last_project.id}-item .project-votes", text: "0")

        within "#project-#{last_project.id}-item" do
          page.find(".budget-list__action").click
        end

        expect(page).to have_selector("#project-#{first_project.id}-item .budget-list__action", text: projects.count)
        expect(page).to have_selector("#project-#{first_project.id}-item .project-votes", text: "1")
        expect(page).to have_selector("#project-#{last_project.id}-item .budget-list__action", text: projects.count - 1)
        expect(page).to have_selector("#project-#{last_project.id}-item .project-votes", text: "2")

        within "#project-#{first_project.id}-item" do
          page.find(".budget-list__action").click
        end

        expect(page).to have_selector("#project-#{first_project.id}-item .budget-list__action", text: "")
        expect(page).to have_selector("#project-#{first_project.id}-item .project-votes", text: "0")
        expect(page).to have_selector("#project-#{last_project.id}-item .budget-list__action", text: projects.count)
        expect(page).to have_selector("#project-#{last_project.id}-item .project-votes", text: "1")
      end
    end
  end
end
