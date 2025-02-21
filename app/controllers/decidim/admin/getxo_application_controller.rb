# frozen_string_literal: true

module Decidim
  module Admin
    class GetxoApplicationController < Decidim::Admin::ApplicationController
      before_action :logged_and_admin?

      private

      def logged_and_admin?
        return if current_user&.admin?

        flash[:alert] = "Admins only!"
        redirect_to decidim_admin.root_path
      end
    end
  end
end
