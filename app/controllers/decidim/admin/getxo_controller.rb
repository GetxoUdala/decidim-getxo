# frozen_string_literal: true

module Decidim
  module Admin
    # The controller to handle getxo webservice sync
    class GetxoController < GetxoApplicationController
      include Paginable
      layout "decidim/admin/getxo"

      helper_method :streets_list, :last_sync, :last_sync_class, :service

      rescue_from Faraday::Error do |error|
        flash[:alert] = t("getxo.connection_error", error: error.message)
        redirect_to streets_admin_getxo_index_path
      end

      def index
        @form = form(CensusAuthorizationHandler).instance
      end

      def check
        @form = form(CensusAuthorizationHandler).from_params(params)
        @response = @form.slim_response
        render :index
      end

      def streets
        respond_to do |format|
          format.html
          format.json do
            render json: json_streets
          end
        end
      end

      def sync
        streets = GetxoStreet.import_streets!(current_organization)
        flash[:notice] = t("getxo.street_sync_success", count: streets.count)
        redirect_to streets_admin_getxo_index_path
      end

      private

      def service(action: "TestDBconnection")
        @service ||= GetxoWebservice.new(action)
      end

      def json_streets
        query = streets_list
        query = if params[:ids]
                  query.where(id: params[:ids])
                else
                  query.where("name ILIKE ?", "%#{params[:q]}%")
                end
        query.map do |item|
          {
            id: item.id,
            text: item.name
          }
        end
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
