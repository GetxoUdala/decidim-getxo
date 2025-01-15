# frozen_string_literal: true

# Admin menu
Decidim.menu :admin_menu do |menu|
  menu.add_item :getxo,
                "Censo Getxo",
                "/admin/getxo",
                icon_name: "dashboard-2-line",
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

Rails.application.config.to_prepare do
  # use captcha on signup
  Decidim::Devise::RegistrationsController.include(Decidim::Devise::RecaptchableSignUp)

  # User select2 to enable multiple zones selector in resource permissions
  Decidim::Admin::ResourcePermissionsController.include(Decidim::Admin::NeedsMultiselectSnippets)
  Decidim::LayoutHelper.prepend(LayoutHelperOverride)
end
