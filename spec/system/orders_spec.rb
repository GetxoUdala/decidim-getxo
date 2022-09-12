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
    let!(:projects) { create_list(:project, 2, budget: budget, budget_amount: 25_000_000) }

    before do
      login_as user, scope: :user
    end

    context "when visiting budget and vote" do
      before do
        page.visit Decidim::EngineRouter.main_proxy(component).budget_projects_path(budget)
      end

      after do
        within "#order-progress" do
          page.find(".budget-summary__progressbox button").click
        end

        within "#budget-confirm" do
          page.find_all(".budget-summary__selected-item").each do |element|
            if element.text.start_with? "1"
              expect(element.text).to include("1 #{last_project.title["en"]}")
            else
              expect(element.text).to include("2 #{first_project.title["en"]}")
            end
          end
          page.find("form button").click
        end

        expect(Decidim::Budgets::Order.find_by(budget: budget, user: user)).to be_checked_out
        expect(Decidim::Budgets::Project.find(first_project.id).confirmed_orders_count).to be 2
        expect(Decidim::Budgets::Project.find(last_project.id).confirmed_orders_count).to be 1
      end

      it "sets order of pick" do
        within "#project-#{first_project.id}-item" do
          page.find(".budget-list__action").click
        end

        expect(page).to have_selector("#project-#{first_project.id}-item .budget-list__action", text: "1")
        expect(page).to have_selector("#project-#{first_project.id}-item .project-votes", text: "1")
        expect(Decidim::Budgets::LineItem.where(order: Decidim::Budgets::Order.find_by(budget: budget, user: user)).count).to be 1

        within "#project-#{last_project.id}-item" do
          page.find(".budget-list__action").click
        end

        expect(page).to have_selector("#project-#{last_project.id}-item .budget-list__action", text: "2")
        expect(page).to have_selector("#project-#{last_project.id}-item .project-votes", text: "2")
        expect(Decidim::Budgets::LineItem.where(order: Decidim::Budgets::Order.find_by(budget: budget, user: user)).count).to be 2

        within "#project-#{first_project.id}-item" do
          page.find(".budget-list__action").click
        end

        expect(page).to have_selector("#project-#{first_project.id}-item .budget-list__action", text: "")
        expect(page).to have_selector("#project-#{first_project.id}-item .project-votes", text: "0")
        expect(page).to have_selector("#project-#{last_project.id}-item .budget-list__action", text: "1")
        expect(page).to have_selector("#project-#{last_project.id}-item .project-votes", text: "1")
        expect(Decidim::Budgets::LineItem.where(order: Decidim::Budgets::Order.find_by(budget: budget, user: user)).count).to be 1

        within "#project-#{first_project.id}-item" do
          page.find(".budget-list__action").click
        end

        expect(page).to have_selector("#project-#{first_project.id}-item .budget-list__action", text: "2")
        expect(page).to have_selector("#project-#{first_project.id}-item .project-votes", text: "2")
        expect(page).to have_selector("#project-#{last_project.id}-item .budget-list__action", text: "1")
        expect(page).to have_selector("#project-#{last_project.id}-item .project-votes", text: "1")
        expect(Decidim::Budgets::LineItem.where(order: Decidim::Budgets::Order.find_by(budget: budget, user: user)).count).to be 2

        expect(Decidim::Budgets::Order.find_by(budget: budget, user: user)).not_to be_checked_out
        expect(first_project.confirmed_orders_count).to be 0
        expect(last_project.confirmed_orders_count).to be 0
      end
    end
  end
end
