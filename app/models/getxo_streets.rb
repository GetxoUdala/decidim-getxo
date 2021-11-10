# frozen_string_literal: true

class GetxoStreets < ApplicationRecord
	def self.import_streets
		service = GetxoWebservice.new("ListadoCalles")
		service.response

		service.response.search("calles").children.map(&:text)
	end
end
