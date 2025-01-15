# frozen_string_literal: true

Rails.application.config.to_prepare do
  Decidim.icons.register(
    name: "dashboard-2-line",
    icon: "dashboard-2-line",
    category: "system",
    description: "",
    engine: :admin_getxo
  )
end
