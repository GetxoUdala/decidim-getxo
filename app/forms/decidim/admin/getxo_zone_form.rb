# frozen_string_literal: true

module Decidim
  module Admin
    class GetxoZoneForm < Form
      mimic :getxo_zone

      attribute :street_id, Integer
      attribute :numbers_constraint, String, default: "all_numbers"
      attribute :numbers_range, String

      validates :street_id, :numbers_constraint, presence: true
      validates :numbers_range, format: { with: GetxoZone::RANGE_REGEXP }, if: ->(form) { form.numbers_range.present? }

      def numbers_constraint_options
        {
          "Todos los números" => "all_numbers",
          "Números pares" => "even_numbers",
          "Números impares" => "odd_numbers"
        }
      end

      # automatic name generation
      def name
        t = "#{street.name} | #{numbers_constraint_options.invert[numbers_constraint]}"
        t = "#{t} | #{numbers_range}" if numbers_range.present?
        t
      end

      private

      def street
        GetxoStreet.find_by(id: street_id, organization: current_organization)
      end
    end
  end
end
