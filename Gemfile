# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

DECIDIM_VERSION = { github: "decidim/decidim", branch: "release/0.29-stable" }.freeze
gem "decidim", DECIDIM_VERSION
gem "decidim-decidim_awesome", github: "decidim-ice/decidim-module-decidim_awesome", branch: "upgrade-0.29"
gem "decidim-term_customizer", github: "mainio/decidim-module-term_customizer", branch: "CodiTramuntana:upgrade/decidim_0.29"

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
  gem "rubocop-rspec", "~> 3.0"
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
