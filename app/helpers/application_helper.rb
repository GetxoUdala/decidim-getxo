# frozen_string_literal: true

module ApplicationHelper
  def recaptcha_tag
    raw %(
      <div class="g-recaptcha" data-sitekey="#{Rails.application.secrets.recaptcha_site_key}"></div>
    )
  end
end
