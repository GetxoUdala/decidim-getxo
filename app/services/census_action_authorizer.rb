# frozen_string_literal: true

class CensusActionAuthorizer < Decidim::Verifications::DefaultActionAuthorizer
  def authorize
    return [:missing, { action: :authorize }] if authorization.blank?

    return [:ok, {}] if zones.blank?
    return [:unauthorized, {}] if authorization_street.blank? || authorization_number.blank?

    @fields = { street: authorization_street, street_number: authorization_number }
    return [:ok, {}] if belongs_to_zone?

    [:unauthorized, { fields: @fields }]
  end

  private

  def zones
    options["zones"]
  end

  def authorization_street
    authorization.metadata["street"]
  end

  def authorization_number
    authorization.metadata["street_number"]
  end

  def belongs_to_zone?
    GetxoZone.where(id: zones.split(",")).find_each do |zone|
      if street_valid?(zone)
        @fields.except!(:street)
        return true if number_valid?(zone)
      end
    end
  end

  def street_valid?(zone)
    authorization_street == zone.street&.name
  end

  def number_valid?(zone)
    return false unless case zone.numbers_constraint
                        when "even_numbers"
                          authorization_number.even?
                        when "odd_numbers"
                          authorization_number.odd?
                        else
                          true
                        end

    return true if zone.numbers_range.blank?

    valids = if zone.numbers_range.include?(",")
               zone.numbers_range.split(",").map(&:to_i)
             else
               a, b = zone.numbers_range.split("-")
               (a.to_i..b.to_i).to_a
             end

    valids.include? authorization_number
  end

  def manifest
    @manifest ||= Decidim::Verifications.find_workflow_manifest(authorization&.name)
  end
end
