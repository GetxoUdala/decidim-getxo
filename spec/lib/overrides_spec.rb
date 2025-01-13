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
      "/app/views/decidim/devise/registrations/new.html.erb" => "5f6f15330839fa55697c4e272767a090",
      "/app/controllers/decidim/devise/registrations_controller.rb" => "f519953daa03df46b98d34b3311a17d0"
    }
  },
  {
    package: "decidim-budgets",
    files: {
      "/app/cells/decidim/budgets/project_vote_button/show.erb" => "d305d378083833b8929fa6eca8b576b3",
      "/app/cells/decidim/budgets/project_votes_count_cell.rb" => "73043088f02c4467923b57860e7e1e4c",
      "/app/cells/decidim/budgets/project_voted_hint_cell.rb" => "efd869a47e6988d9116113e7c80f507b",
      "/app/models/decidim/budgets/line_item.rb" => "050834fb634eaae9d0f696ac2d55adc4",
      "/app/models/decidim/budgets/order.rb" => "b5fc05ade80b231b46b1038cabbe0848",
      "/app/models/decidim/budgets/project.rb" => "87923143ea9e718b9c9528d29f8415a0",
      "/app/views/decidim/budgets/line_items/update_budget.js.erb" => "9c89b43b4e6548c9697d1942e71af9fb",
      "/app/views/decidim/budgets/projects/_budget_confirm.html.erb" => "8ff47688f3aa43e006f9bb35e4d37586",
      "/app/views/decidim/budgets/order_summary_mailer/order_summary.html.erb" => "87247a9231673eecc4103c95a9581f1d",
      "/app/views/decidim/budgets/projects/_order_selected_projects.html.erb" => "bd005e4d09212cca3cf0a40e2a15298e"

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
