# frozen_string_literal: true

# Admin menu
Decidim.menu :admin_menu do |menu|
  menu.item "Censo Getxo",
            admin_getxo_index_path,
            icon_name: "dial",
            position: 1.2,
            active: :inclusive
end

# Multiselect for street verificator