# frozen_string_literal: true

class GetxoStreets < ApplicationRecord
	def self.import_streets
		service = GetxoStreets.new("ListadoCalles")
		service.response
	end
end
