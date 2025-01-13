# frozen_string_literal: true

require "decidim/core/test/factories"
require "decidim/proposals/test/factories"
require "decidim/decidim_awesome/test/factories"

FactoryBot.define do
  factory :getxo_street, class: "GetxoStreet" do
    name { Faker::Address.street_name }
    organization
  end
  factory :getxo_zone, class: "GetxoZone" do
    name { Faker::Address.street_name }
    street { create(:getxo_street) }
    organization
    numbers_constraint { "all_numbers" }
  end
end
