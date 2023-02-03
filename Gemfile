# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

DECIDIM_VERSION = { git: "https://github.com/decidim/decidim", branch: "release/0.26-stable" }.freeze
gem "decidim", DECIDIM_VERSION
gem "decidim-consultations", DECIDIM_VERSION
# gem "decidim-initiatives", DECIDIM_VERSION
gem "decidim-decidim_awesome"
gem "decidim-term_customizer", git: "https://github.com/openpoke/decidim-module-term_customizer"
gem "decidim-verifications", DECIDIM_VERSION

gem "deface"
gem "bootsnap", "~> 1.7"

gem "puma", ">= 5.3.1"

gem "virtus-multiparams"

gem "faker", "~> 2.14"
gem "ruby-ntlm"
gem "sentry-rails"
gem "sentry-ruby"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.1"
  gem "rubocop-faker"
  gem "spring", "~> 2.1"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 4.2"
  gem "xliffle"

  gem "capistrano", "~> 3.15"
  gem "capistrano-bundler", "~> 2.0", require: false
  gem "capistrano-passenger", "~> 0.2.0", require: false
  gem "capistrano-rails", "~> 1.6", require: false
  gem "capistrano-rails-console", require: false
  gem "capistrano-rbenv", "~> 2.2", require: false
end

group :production do
  gem "figaro", "~> 1.2"
  gem "passenger", "~> 6.0"
  gem "sidekiq", "<7"
  gem "sidekiq-cron"
end
