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
      "/app/views/decidim/devise/registrations/new.html.erb" => "6f8ab8020d181e9ed5cd9cf9de0c97ae",
      "/app/controllers/decidim/devise/registrations_controller.rb" => "d5f7e3d61b62c3ce2704ecd48f2a080c",
      "/app/views/layouts/decidim/header/_main.html.erb" => "a6496ec11e073062743a927ee3c8bd3c"
    }
  },
  {
    package: "decidim-budgets",
    files: {
      "/app/cells/decidim/budgets/project_vote_button/show.erb" => "7736c0be52dc29883f069983ba01024e",
      "/app/cells/decidim/budgets/project_votes_count_cell.rb" => "3e3bc22b8c7fc749409da9946e5176b4",
      "/app/cells/decidim/budgets/project_voted_hint_cell.rb" => "95f359b2f5e7c6248283df7e8409c24a",
      "/app/models/decidim/budgets/line_item.rb" => "050834fb634eaae9d0f696ac2d55adc4",
      "/app/models/decidim/budgets/order.rb" => "b5fc05ade80b231b46b1038cabbe0848",
      "/app/models/decidim/budgets/project.rb" => "f8bedb49a880157094bde68c50698644",
      "/app/views/decidim/budgets/line_items/update_budget.js.erb" => "8d526e33ee262e6cdce7c96cf115ee35",
      "/app/views/decidim/budgets/projects/_budget_confirm.html.erb" => "1326367362a856875cfdbf8f3ff2ea1e",
      "/app/views/decidim/budgets/order_summary_mailer/order_summary.html.erb" => "87247a9231673eecc4103c95a9581f1d"

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
