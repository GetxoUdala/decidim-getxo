# frozen_string_literal: true

module PermissionFormOverride
  extend ActiveSupport::Concern

  included do
    validate :handler_options_values_must_be_valid
  end

  private

  def handler_options_values_must_be_valid
    authorization_handlers_names.each do |handler_name|
      next if handler_name.blank?
      next unless manifest(handler_name)

      schema = options_schema(handler_name)
      next if schema.valid?

      schema.errors.each do |error|
        errors.add(:base, humanized_options_error(handler_name, error))
      end
    end
  end

  def humanized_options_error(handler_name, error)
    label = I18n.t(
      error.attribute,
      scope: "decidim.authorization_handlers.#{handler_name}.fields",
      default: error.attribute.to_s.humanize
    )
    "#{label}: #{error.message}"
  end
end
