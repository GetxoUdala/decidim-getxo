# frozen_string_literal: true

Rails.application.config.to_prepare do
  Decidim::Budgets::Order.class_eval do
    def sorted_projects
      projects.includes(:line_items).order(decidim_budgets_line_items: :asc)
    end
  end

  Decidim::Budgets::LineItem.class_eval do
    has_one :budget, through: :project, foreign_key: "decidim_budgets_budget_id", class_name: "Decidim::Budgets::Budget"

    def position
      order.line_items.pluck(:id).find_index(id)
    end 
    
    def score
      project_count - position
    end
    
    def project_count
      @project_count ||= budget.projects.count  
    end
  end
  
  Decidim::Budgets::ProjectVotedHintCell.class_eval do
    private
    
    def line_item
      current_order.line_items.find_by(project: model)
    end

    def hint
      contents = []
      contents << icon("check", role: "img")
      contents << " "
      contents << t("decidim.budgets.projects.project.you_voted")
      contents << " "
      contents << content_tag(:div, class: "badge success budget-summary_project-score") do
        line_item.score
      end
    end
  end
end
