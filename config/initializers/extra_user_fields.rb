# frozen_string_literal: true

Decidim::ExtraUserFields.configure do |config|
  config.insight_fields = %w(gender age_span)
  config.genders = [:female, :male]
  config.insight_age_spans = %w(up_to_17 18_to_24 25_to_34 35_to_44 45_to_54 55_to_64 65_to_74 75_or_more)
end
