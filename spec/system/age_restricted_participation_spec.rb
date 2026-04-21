# frozen_string_literal: true

require "rails_helper"

describe "Age-restricted participation in a proposals component", :js do # rubocop:disable RSpec/DescribeClass
  let(:organization) { create(:organization, available_authorizations: %w(census_authorization_handler)) }
  let!(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
  let!(:user) { create(:user, :confirmed, organization:) }
  let!(:component) do
    create(:proposal_component,
           :with_likes_enabled,
           :with_votes_enabled,
           :with_creation_enabled,
           participatory_space: participatory_process)
  end
  let!(:proposal) { create(:proposal, component:) }
  let!(:comment) { create(:comment, commentable: proposal) }

  let(:minimum_age) { 18 }
  let(:handler_options) { { "options" => { "minimum_age" => minimum_age.to_s } } }
  let(:permissions) do
    %w(like vote comment vote_comment create).index_with do
      { "authorization_handlers" => { "census_authorization_handler" => handler_options } }
    end
  end

  before do
    component.update!(permissions: permissions)
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  def visit_proposal
    visit Decidim::ResourceLocatorPresenter.new(proposal).path
  end

  shared_examples "opens the authorization modal with" do |expected_text|
    it "when clicking Like" do
      visit_proposal
      within "#resource-#{proposal.id}-like-block" do
        click_on "Like"
      end

      expect(page).to have_css("#authorizationModal", visible: :visible)
      within "#authorizationModal" do
        expect(page).to have_content(expected_text)
      end
    end

    it "when supporting the proposal" do
      visit_proposal
      click_on "Support"

      expect(page).to have_css("#authorizationModal", visible: :visible)
      within "#authorizationModal" do
        expect(page).to have_content(expected_text)
      end
    end

    it "when up-voting a comment" do
      visit_proposal
      within "#comment_#{comment.id}" do
        page.find(".js-comment__votes--up").click
      end

      expect(page).to have_css("#authorizationModal", visible: :visible)
      within "#authorizationModal" do
        expect(page).to have_content(expected_text)
      end
    end
  end

  shared_examples "blocks commenting with an inline verification warning" do
    it "hides the comment form and shows the warning" do
      visit_proposal

      expect(page).to have_content("You need to be verified to comment at this moment")
      expect(page).to have_no_css("form.new_comment")
    end
  end

  context "when the user has no census authorization" do
    it_behaves_like "opens the authorization modal with", "In order to perform this action"
    it_behaves_like "blocks commenting with an inline verification warning"
  end

  context "when the user is authorized but below the minimum age" do
    let!(:authorization) do
      create(:authorization, :granted,
             name: "census_authorization_handler",
             user:,
             metadata: { "date_of_birth" => 10.years.ago.strftime("%Y-%m-%d") })
    end

    it_behaves_like "opens the authorization modal with", "Sorry, you cannot perform this action as some of your authorization data does not match"
    it_behaves_like "blocks commenting with an inline verification warning"

    it "does not expose the age reason in the authorization modal" do
      visit_proposal
      within "#resource-#{proposal.id}-like-block" do
        click_on "Like"
      end

      within "#authorizationModal" do
        expect(page).to have_no_content(/minimum age|maximum age|too old|not old enough/i)
      end
    end
  end

  context "when the user is authorized and within the age range" do
    let!(:authorization) do
      create(:authorization, :granted,
             name: "census_authorization_handler",
             user:,
             metadata: { "date_of_birth" => 30.years.ago.strftime("%Y-%m-%d") })
    end

    it "can like the proposal" do
      visit_proposal
      within "#resource-#{proposal.id}-like-block" do
        click_on "Like"
        expect(page).to have_css('#like-button[aria-label="Undo the like"]')
      end
    end

    it "can support the proposal" do
      visit_proposal
      click_on "Support"

      expect(page).to have_css("#authorizationModal", visible: :hidden)
      expect(page).to have_content("Already supported")
    end

    it "can up-vote a comment" do
      visit_proposal
      within "#comment_#{comment.id}" do
        page.find(".js-comment__votes--up").click
      end

      expect(page).to have_css(".js-comment__votes--up", text: /1/)
    end

    it "can access the comment form" do
      visit_proposal

      expect(page).to have_no_content("You need to be verified to comment at this moment")
      expect(page).to have_css("form.new_comment")
    end
  end
end
