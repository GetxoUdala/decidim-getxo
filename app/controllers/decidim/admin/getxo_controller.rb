# frozen_string_literal: true

module Decidim
  module Admin
    # The controller to handle user groups creation
    class GetxoController < Decidim::Admin::ApplicationController
      include Paginable
      layout "decidim/admin/getxo"

      helper_method :streets_list, :last_sync, :last_sync_class, :service

      def index
        @form = form(CensusAuthorizationHandler).instance
      end

      def check
        @form = form(CensusAuthorizationHandler).from_params(params)
        @response = @form.slim_response
        render :index
      end

      def streets; end

      def sync
        GetxoStreet.import_streets!(current_organization)
        redirect_to streets_admin_getxo_index_path
      end

      private

      def service(action: "TestDBConnection")
        @service ||= GetxoWebservice.new(action)
      end

      def streets_list
        paginate(GetxoStreet.where(organization: current_organization).order(name: :asc))
      end

      def last_sync
        @last_sync ||= GetxoStreet.where(organization: current_organization).select(:updated_at).order(updated_at: :desc).last&.updated_at
      end

      def last_sync_class(datetime)
        return unless datetime

        return "alert" if datetime < 1.week.ago
        return "warning" if datetime < 1.day.ago

        "success"
      end

      def per_page
        50
      end
    end
  end
end
