# frozen_string_literal: true

class CensusActionAuthorizer < Decidim::Verifications::DefaultActionAuthorizer
  def authorize
    return [:missing, { action: :authorize }] if authorization.blank?

    return [:ok, {}] if streets_empty?

    return [:unauthorized, { fields: { "streets": "..." } }] if authorization_streets.blank?
    return [:ok, {}] if belongs_to_street?

    [:unauthorized, {}]
  end

  private

  def streets_empty?
    options["streets"].blank?
  end

  def authorization_streets
    authorization.metadata["streets"] || []
  end

  def belongs_to_street?
    allowed_streets = GetxoStreet.where(id: options["streets"].split(","))&.pluck(:name)
    allowed_streets&.detect { |street| authorization_streets.include?(street) }
  end

  def manifest
    @manifest ||= Decidim::Verifications.find_workflow_manifest(authorization&.name)
  end
end
