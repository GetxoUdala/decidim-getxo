# frozen_string_literal: true

Rails.application.config.to_prepare do
  Decidim::Budgets::Order.class_eval do
    def sorted_projects
      projects.joins(:line_items).order(decidim_budgets_line_items: :asc)
    end
  end
end
