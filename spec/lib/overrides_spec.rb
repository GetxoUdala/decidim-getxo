# frozen_string_literal: true

require "rails_helper"

# We make sure that the checksum of the file overriden is the same
# as the expected. If this test fails, it means that the overriden
# file should be updated to match any change/bug fix introduced in the core
checksums = [
  {
    package: "decidim-core",
    files: {
      # layouts
      "/app/views/decidim/devise/registrations/new.html.erb" => "861b8821bbdc05e7b337fcdb921415ba",
      "/app/controllers/decidim/devise/registrations_controller.rb" => "3b9d431d19e456aeab3eb861b6189bf4",
      "/app/views/layouts/decidim/header/_main.html.erb" => "a090eeca739613446d2eab8f4de513b1"
    }
  },
  {
    package: "decidim-budgets",
    files: {
      "/app/cells/decidim/budgets/project_vote_button/show.erb" => "2eaf41436c12730bf6f41f6f842b5191",
      "/app/cells/decidim/budgets/project_votes_count_cell.rb" => "2fca2b7c58fb8513d949af171ef2e084",
      "/app/cells/decidim/budgets/project_voted_hint_cell.rb" => "c4892582c28aa52a5a00fc04936a4418",
      "/app/models/decidim/budgets/line_item.rb" => "050834fb634eaae9d0f696ac2d55adc4",
      "/app/models/decidim/budgets/order.rb" => "cb58696f8ccee79c81211a9d48e5689a",
      "/app/models/decidim/budgets/project.rb" => "d6589ccb7d3e18e58aaafa13a37e9947",
      "/app/views/decidim/budgets/line_items/update_budget.js.erb" => "982afbfebd432d24dd01be8990923abe",
      "/app/views/decidim/budgets/projects/_budget_confirm.html.erb" => "9e4af16df8b72afc6a2d72a3d1184dcd",
      "/app/views/decidim/budgets/order_summary_mailer/order_summary.html.erb" => "073439e07191ed40e0bd1d2fee53cbfe"
    }
  }
]

describe "Overriden files", type: :view do
  checksums.each do |item|
    spec = Gem::Specification.find_by_name(item[:package])
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
