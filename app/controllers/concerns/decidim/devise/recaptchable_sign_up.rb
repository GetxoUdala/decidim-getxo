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

        # rubocop:disable Rails/LexicallyScopedActionFilter
        before_action :verify_recaptcha, only: :create
        # rubocop:enable Rails/LexicallyScopedActionFilter

        private

        def verify_recaptcha
          secret_key = ENV.fetch("RECAPTCHA_SECRET_KEY", nil)
          return if secret_key.blank?

          token = params["g-recaptcha-response"]
          return reject_recaptcha if token.blank?

          begin
            uri = URI.parse("https://www.google.com/recaptcha/api/siteverify")
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            http.read_timeout = 5
            http.open_timeout = 5

            request = Net::HTTP::Post.new(uri.path)
            request.set_form_data(
              secret: secret_key,
              response: token,
              remoteip: request.remote_ip
            )

            response = http.request(request)

            return reject_recaptcha if response.nil? || response.body.blank?

            json = JSON.parse(response.body)
            verified = json["success"]
            score = json["score"].to_f

            # reCAPTCHA v3 returns a score between 0 (bot) and 1 (human)
            # Adjust threshold as needed (0.5 is recommended)
            score_threshold = ENV.fetch("RECAPTCHA_SCORE_THRESHOLD", "0.5").to_f

            unless verified && score >= score_threshold
              Rails.logger.warn("reCAPTCHA verification failed - success: #{verified}, score: #{score}")
              reject_recaptcha
            end
          rescue StandardError => e
            Rails.logger.error("reCAPTCHA verification error: #{e.class} - #{e.message}")
            reject_recaptcha
          end
        end

        def reject_recaptcha
          flash[:alert] = t("recaptcha.errors.verification_failed")
          redirect_to new_user_registration_path
        end
      end
    end
  end
end
