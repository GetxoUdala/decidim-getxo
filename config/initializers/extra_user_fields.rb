# frozen_string_literal: true

Decidim::ExtraUserFields.configure do |config|
  config.insight_fields = %w(gender age_span)
  config.genders = [:female, :male]
  config.insight_age_spans = ["16-17", "18-24", "25-34", "35-44", "45-54", "55-64", "65-74", "75+"]
end
