# frozen_string_literal: true

class GetxoStreet < ApplicationRecord
  belongs_to :organization,
             foreign_key: "decidim_organization_id",
             class_name: "Decidim::Organization"

  def self.import_streets!(organization)
    import_streets.each do |street|
      s = GetxoStreet.find_or_initialize_by(name: street, organization:)
      # rubocop:disable Rails/SkipsModelValidations
      s.touch if s.persisted?
      # rubocop:enable Rails/SkipsModelValidations
      s.save!
    end
  end

  def self.import_streets
    service = GetxoWebservice.new("ListadoCalles")
    service.response

    service.response.search("calles").children.map { |node| node.text.strip }
  end
end
