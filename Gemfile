# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

DECIDIM_VERSION = { git: "https://github.com/decidim/decidim", branch: "release/0.22-stable" }.freeze
gem "decidim", DECIDIM_VERSION
# gem "decidim-consultations", DECIDIM_VERSION
# gem "decidim-initiatives", DECIDIM_VERSION
gem "decidim-verifications", DECIDIM_VERSION

gem "bootsnap", "~> 1.4"

gem "puma", "~> 4.3.3"
gem "uglifier", "~> 4.1"

gem "virtus-multiparams"

gem "delayed_job_web"
gem "faker", "~> 1.9"
gem "figaro", "~> 1.2"
gem "rspec"
gem "ruby-ntlm"
gem "sentry-raven"
gem "whenever", require: false

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 3.5"

  gem "capistrano"
  gem "capistrano-bundler"
  gem "capistrano-passenger", ">= 0.1.1"
  gem "capistrano-rails"
  gem "capistrano-rbenv"
end

group :production do
  gem "daemons", "~> 1.3"
  gem "delayed_job_active_record", "~> 4.1"
  gem "passenger", "~> 6.0"
end
