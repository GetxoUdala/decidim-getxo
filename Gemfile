# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

DECIDIM_VERSION = { github: "decidim/decidim", branch: "backport/0.28/use-leaflet-tilelayer-here-v20-14164" }.freeze
gem "decidim", DECIDIM_VERSION
gem "decidim-decidim_awesome"
gem "decidim-term_customizer", github: "mainio/decidim-module-term_customizer", branch: "l10n_main"

gem "bootsnap", "~> 1.4"
gem "deface", ">= 1.9"
gem "health_check"
gem "puma", ">= 6.3.1"
gem "rorvswild"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "brakeman", "~> 5.4"
  gem "decidim-dev", DECIDIM_VERSION
  gem "faker", "~> 3.2"
  gem "rubocop-rspec", "~> 2.20.0"
end

group :development do
  gem "letter_opener_web"
  gem "listen"
  gem "rubocop-faker"
  gem "spring"
  gem "spring-watcher-listen"
  gem "web-console"
  gem "xliffle"
end

group :production do
  gem "sidekiq"
  gem "sidekiq-cron"
end
