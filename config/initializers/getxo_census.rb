# frozen_string_literal: true

# Admin menu
Decidim.menu :admin_menu do |menu|
  menu.item "Censo Getxo",
            "/admin/getxo",
            icon_name: "dial",
            position: 1.2,
            active: :inclusive
end

# Multiselect for street verificator
Decidim::Verifications.register_workflow(:census_authorization_handler) do |workflow|
  workflow.form = "CensusAuthorizationHandler"
  workflow.action_authorizer = "CensusActionAuthorizer"

  workflow.options do |options|
    options.attribute :zones, type: :string
  end
end

# User select2 to enable multiple zones selector in resource permissions
Rails.application.config.to_prepare do
  Decidim::Admin::ResourcePermissionsController.include(Decidim::Admin::NeedsMultiselectSnippets)
end