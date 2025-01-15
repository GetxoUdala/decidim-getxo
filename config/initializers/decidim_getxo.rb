# frozen_string_literal: true

Rails.application.config.to_prepare do
  # Register the new icons
  Decidim.icons.register(name: "dashboard-2-line", icon: "dashboard-2-line", category: "system", description: "", engine: :admin_getxo)

  # Register the new menu item
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
end
