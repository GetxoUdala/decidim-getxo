# frozen_string_literal: true

module ApplicationHelper
  def recaptcha_tag
    raw %(
      <div class="g-recaptcha" data-sitekey="#{ENV.fetch("RECAPTCHA_SITE_KEY", nil)}"></div>
    )
  end
end
