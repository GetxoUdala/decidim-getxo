# frozen_string_literal: true

Rails.application.config.to_prepare do
  Decidim::Budgets::Project.class_eval do
    def confirmed_votes_count
      query = <<-SQL.squish
        SELECT SUM(score) FROM (
          SELECT dbli.*, RANK() OVER (
            PARTITION BY dbli.decidim_order_id
            ORDER BY dbli.id ASC
          ) score
          FROM decidim_budgets_orders dbo
          JOIN decidim_budgets_line_items dbli ON dbo.id = dbli.decidim_order_id AND dbo.checked_out_at IS NOT NULL
          JOIN decidim_budgets_projects dbp ON dbp.id = dbli.decidim_project_id
        ) ranks
        WHERE decidim_project_id = #{id}
      SQL
      @count ||= ActiveRecord::Base.connection.execute(Arel.sql(query))[0]["sum"].to_i
    end

    def confirmed_orders_count
      confirmed_votes_count
    end
  end

  Decidim::Budgets::Order.class_eval do
    def sorted_projects
      projects.includes(:line_items).order(decidim_budgets_line_items: :asc)
    end

    def line_item_for(project)
      line_items.find_by(project: project)
    end

    def count_for(project)
      line_item_for(project)&.count || 0
    end

    def score_for(project)
      line_item_for(project)&.score || 0
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

    def count
      position + 1
    end

    def project_count
      @project_count ||= budget.projects.count
    end
  end

  Decidim::Budgets::ProjectVotesCountCell.class_eval do
    delegate :current_order, to: :controller

    def count
      @count ||= if current_order.checked_out_at
                   model.confirmed_orders_count
                 else
                   model.confirmed_orders_count + current_order.count_for(model)
                 end
    end

    def content
      if options[:layout] == :one_line
        safe_join([count, " ", label(t("decidim.budgets.projects.project.votes", count: count))])
      else
        safe_join([number, label(t("decidim.budgets.projects.project.votes", count: count))])
      end
    end

    def number
      content_tag :div, count, class: "text-large"
    end
  end

  Decidim::Budgets::ProjectVotedHintCell.class_eval do
    private

    def hint
      contents = []
      contents << icon("check", role: "img")
      contents << " "
      contents << t("decidim.budgets.projects.project.you_voted")
      contents << " "
      contents << content_tag(:div, class: "badge success budget-summary_project-score") do
        current_order.score_for(model)
      end
    end
  end
end
