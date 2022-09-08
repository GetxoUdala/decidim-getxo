# frozen_string_literal: true

require "rails_helper"

# We make sure that the checksum of the file overriden is the same
# as the expected. If this test fails, it means that the overriden
# file should be updated to match any change/bug fix introduced in the core
checksums = [
  {
    package: "decidim-core",
    files: {
      # mailers
      "/app/mailers/decidim/application_mailer.rb" => "fcd6a9ad382ef76f0a7af216b13b96cb",
      # layouts
      "/app/views/layouts/decidim/mailer.html.erb" => "5bbe335c1dfd02f8448af287328a49dc",
      "/app/views/decidim/devise/sessions/new.html.erb" => "1da8569a34bcd014ffb5323c96391837",
      "/app/controllers/decidim/devise/registrations_controller.rb" => "abcc9270c6191f89d7b229e481b51e9a"
    }
  },
  {
    package: "decidim-budgets",
    files: {
      "/app/cells/decidim/budgets/project_votes_count_cell.rb" => "73043088f02c4467923b57860e7e1e4c",
      "/app/cells/decidim/budgets/project_voted_hint_cell.rb" => "afb7b7d549d6ece826749b3d85f13c3e",
      "/app/models/decidim/budgets/line_item.rb" => "050834fb634eaae9d0f696ac2d55adc4",
      "/app/models/decidim/budgets/order.rb" => "2e73ee587cd7ec4562ad020342671f39",
      "/app/models/decidim/budgets/project.rb" => "5e20e93f34bbe586c95b9aa4374b39f4"
    }
  }
]

describe "Overriden files", type: :view do
  checksums.each do |item|
    # rubocop:disable Rails/DynamicFindBy
    spec = ::Gem::Specification.find_by_name(item[:package])
    # rubocop:enable Rails/DynamicFindBy
    item[:files].each do |file, signature|
      it "#{spec.gem_dir}#{file} matches checksum" do
        expect(md5("#{spec.gem_dir}#{file}")).to eq(signature)
      end
    end
  end

  private

  def md5(file)
    Digest::MD5.hexdigest(File.read(file))
  end
end
