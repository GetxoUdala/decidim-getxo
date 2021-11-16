# frozen_string_literal: true

class GetxoZone < ApplicationRecord
  RANGE_REGEXP = /\A[([0-9]+)([,\-]{0,1})([0-9]+)]+\z/.freeze

  belongs_to :organization,
             foreign_key: "decidim_organization_id",
             class_name: "Decidim::Organization"
  belongs_to :street,
             class_name: "GetxoStreet"
  enum numbers_constraint: { all_numbers: 0, odd_numbers: 1, even_numbers: 2 }

  validates :street_id, :numbers_constraint, presence: true
  validates :numbers_range, format: { with: GetxoZone::RANGE_REGEXP }, if: ->(form) { form.numbers_range.present? }
  validate :unique_combination

  private

  def unique_combination
    return unless GetxoZone.exists?(street_id: street_id, organization: organization, numbers_constraint: numbers_constraint, numbers_range: numbers_range)

    errors.add(:name, :invalid)
  end
end
