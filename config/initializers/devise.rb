# frozen_string_literal: true

Devise.setup do |config|
  config.confirm_within = 12.hours
end
