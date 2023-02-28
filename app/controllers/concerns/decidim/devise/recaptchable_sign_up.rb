# frozen_string_literal: true

require "net/https"

module Decidim
  module Devise
    module RecaptchableSignUp
      extend ActiveSupport::Concern

      included do
        # https://dev.to/morinoko/adding-recaptcha-v3-to-a-rails-app-without-a-gem-46jj
        # https://www.google.com/recaptcha/admin/site/507608105/setup
        # https://developers.google.com/recaptcha/docs/verify
        # https://developers.google.com/recaptcha/docs/display

        RECAPTCHA_MINIMUM_SCORE = 0.5

        # rubocop:disable Rails/LexicallyScopedActionFilter
        before_action :verify_recaptcha, only: :create
        # rubocop:enable Rails/LexicallyScopedActionFilter

        private

        def verify_recaptcha
          token = params["g-recaptcha-response"]

          secret_key = Rails.application.secrets[:recaptcha_secret_key]

          uri = URI.parse("https://www.google.com/recaptcha/api/siteverify?secret=#{secret_key}&response=#{token}")

          response = Net::HTTP.get_response(uri)

          # https = Net::HTTP.new(uri.host, uri.port)
          # https.use_ssl = true
          # req = Net::HTTP::Post.new(uri.path)

          # res = https.request(req)
          # puts "Response #{res.code} #{res.message}: #{res.body}"

          json = JSON.parse(response.body)

          verified = json["success"]

          unless verified
            flash[:alert] = t("recaptcha.errors.verification_failed")
            redirect_to new_user_registration_path
          end
        end
      end
    end
  end
end
