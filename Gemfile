# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

DECIDIM_VERSION = { git: "https://github.com/decidim/decidim", branch: "release/0.27-stable" }.freeze
gem "decidim", DECIDIM_VERSION
gem "decidim-consultations", DECIDIM_VERSION
# gem "decidim-initiatives", DECIDIM_VERSION
gem "decidim-decidim_awesome", git: "https://github.com/decidim-ice/decidim-module-decidim_awesome"
gem "decidim-friendly_signup", git: "https://github.com/OpenSourcePolitics/decidim-module-friendly_signup.git"
gem "decidim-term_customizer", github: "mainio/decidim-module-term_customizer", branch: "release/0.27-stable"
gem "decidim-verifications", DECIDIM_VERSION

gem "bootsnap", "~> 1.7"
gem "deface"

gem "puma", ">= 5.3.1"

gem "ruby-ntlm"
# net/smtp 0.4 does not work well with NTLM authentication
gem "net-smtp", "~> 0.3.3"
gem "sentry-rails"
gem "sentry-ruby"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri
  gem "faker", "~> 2.14"

  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.1"
  gem "rubocop-faker"
  gem "spring", "~> 4.1.1"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 4.2"
  gem "xliffle"
end

group :production do
  gem "sidekiq", "<7"
  gem "sidekiq-cron"
end
