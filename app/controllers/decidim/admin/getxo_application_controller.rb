# frozen_string_literal: true

module Decidim
  module Admin
    class GetxoApplicationController < Decidim::Admin::ApplicationController
      before_action :logged_and_admin?

      private

      def logged_and_admin?
        return true if current_user&.admin?

        flash[:alert] = "Admins only!" # rubocop:disable Rails/I18nLocaleTexts:
        redirect_to decidim_admin.root_path
      end
    end
  end
end
