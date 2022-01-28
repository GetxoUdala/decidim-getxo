# frozen_string_literal: true

module ApplicationHelper
  def include_recaptcha_js
    raw %(
      <script src="https://www.google.com/recaptcha/api.js" async defer></script>
    )
  end

  def recaptcha_tag
    raw %(
      <div class="g-recaptcha" data-sitekey="#{Rails.application.secrets.recaptcha_site_key}"></div>
    )
  end
end
