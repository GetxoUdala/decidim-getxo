# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs")
Decidim::Webpacker.register_entrypoints(
  resource_permissions_multiselect: "#{base_path}/app/packs/entrypoints/resource_permissions_multiselect.js"
)
