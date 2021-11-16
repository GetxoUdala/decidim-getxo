# frozen_string_literal: true

class CensusActionAuthorizer < Decidim::Verifications::DefaultActionAuthorizer
  def authorize
    return [:missing, { action: :authorize }] if authorization.blank?

    return [:ok, {}] if streets_empty?

    return [:unauthorized, {}] if authorization_street.blank?
    return [:ok, {}] if belongs_to_street?

    [:unauthorized, { fields: { "street": authorization_street } }]
  end

  private

  def streets_empty?
    options["streets"].blank?
  end

  def authorization_street
    authorization.metadata["street"] || ""
  end

  def belongs_to_street?
    allowed_streets = GetxoStreet.where(id: options["streets"].split(","))&.pluck(:name)
    allowed_streets.include?(authorization_street)
  end

  def manifest
    @manifest ||= Decidim::Verifications.find_workflow_manifest(authorization&.name)
  end
end
