# frozen_string_literal: true

module Decidim
  module Admin
    class CreateGetxoZone < Decidim::Command
      def initialize(form)
        @form = form
      end

      def call
        return broadcast(:invalid) unless form.valid?

        begin
          create_zone!
        rescue StandardError => e
          return broadcast(:invalid, e.message)
        end

        broadcast(:ok, zone)
      end

      private

      attr_reader :form, :zone

      def create_zone!
        GetxoZone.create!(
          organization: form.current_organization,
          street_id: form.street_id,
          numbers_constraint: form.numbers_constraint,
          numbers_range: form.numbers_range,
          name: form.name
        )
      end
    end
  end
end
