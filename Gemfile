# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

DECIDIM_VERSION = { github: "decidim/decidim", branch: "release/0.29-stable" }.freeze
gem "decidim", DECIDIM_VERSION
gem "decidim-decidim_awesome", github: "decidim-ice/decidim-module-decidim_awesome", branch: "main"
gem "decidim-term_customizer", github: "openpoke/decidim-module-term_customizer", branch: "main"

gem "bootsnap", "~> 1.4"
gem "deface", ">= 1.9"
gem "health_check"
gem "puma", ">= 6.3.1"
gem "rails_semantic_logger"
gem "sentry-rails"
gem "sentry-ruby"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "brakeman", "~> 5.4"
  gem "decidim-dev", DECIDIM_VERSION
  gem "faker", "~> 3.2"
  gem "rubocop-rspec"
end

group :development do
  gem "letter_opener_web"
  gem "listen"
  gem "rubocop-faker"
  gem "web-console"
  gem "xliffle"
end

group :production do
  gem "sidekiq"
  gem "sidekiq-cron"
end
