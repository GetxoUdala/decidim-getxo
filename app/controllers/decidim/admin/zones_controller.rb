# frozen_string_literal: true

module Decidim
  module Admin
    # The controller to handle getxo webservice sync
    class ZonesController < Decidim::Admin::ApplicationController
      include Paginable
      layout "decidim/admin/getxo"

      helper_method :zone_list, :streets, :zone

      def index
        respond_to do |format|
          format.html
          format.json do
            render json: json_zones
          end
        end
      end

      def new
        @form = form(GetxoZoneForm).instance
      end

      def edit
        @form = form(GetxoZoneForm).from_model(zone)
      end

      def create
        @form = form(GetxoZoneForm).from_params(params)
        CreateGetxoZone.call(@form) do
          on(:ok) do
            flash[:notice] = "Nueva zona creada correctamente"
            redirect_to admin_getxo_zones_path
          end

          on(:invalid) do |error|
            flash.now[:alert] = "Ha ocurrido un error al crear la zona: #{error} - La combinación ya existe."
            render :new
          end
        end
      end

      def update
        @form = form(GetxoZoneForm).from_params(params)
        UpdateGetxoZone.call(@form) do
          on(:ok) do
            flash[:notice] = "Zona actualizada correctamente"
            redirect_to admin_getxo_zones_path
          end

          on(:invalid) do |error|
            flash.now[:alert] = "Ha ocurrido un error al actualizar la zona: #{error} - La combinación ya existe."
            render :edit
          end
        end
      end

      def destroy
        zone.destroy!

        flash[:notice] = "Zona eliminada correctament"

        redirect_to admin_getxo_zones_path
      end

      def zones
        respond_to do |format|
          format.html
          format.json do
            render json: json_zones
          end
        end
      end

      private

      def zone
        GetxoZone.find(params[:id])
      end

      def streets
        GetxoStreet.where(organization: current_organization).order(name: :asc)
      end

      def json_zones
        query = zone_list
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

      def zone_list
        paginate(GetxoZone.where(organization: current_organization).order(name: :asc))
      end

      def per_page
        50
      end
    end
  end
end
