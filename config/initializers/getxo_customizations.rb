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

Decidim.menu :admin_getxo_menu do |menu|
  menu.add_item :title,
                "Webservice Sync",
                "#",
                position: 1

  menu.add_item :check,
                "Check",
                Decidim::Admin::Engine.routes.url_helpers.admin_getxo_index_path,
                position: 2,
                active: is_active_link?(Decidim::Admin::Engine.routes.url_helpers.admin_getxo_index_path)

  menu.add_item :zones,
                "Zonas",
                Decidim::Admin::Engine.routes.url_helpers.admin_getxo_zones_path,
                position: 3,
                active: is_active_link?(Decidim::Admin::Engine.routes.url_helpers.admin_getxo_zones_path)

  menu.add_item :streets,
                "Calles",
                Decidim::Admin::Engine.routes.url_helpers.streets_admin_getxo_index_path,
                position: 4,
                active: is_active_link?(Decidim::Admin::Engine.routes.url_helpers.streets_admin_getxo_index_path)
end

# Register the new icons
Decidim.icons.register(name: "dashboard-2-line", icon: "dashboard-2-line", category: "system", description: "", engine: :admin_getxo)
Decidim.icons.register(name: "check", icon: "check", category: "system", description: "", engine: :core)

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
