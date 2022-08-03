# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell renders the vote count.
    # Two possible layouts: One or two lines
    class ProjectVotesCountCell < Decidim::ViewModel
      include Decidim::IconHelper
      delegate :show_votes_count?, to: :controller

      def show
        return unless show_votes_count?

        content_tag :span, content, class: css_class
      end

      private

      def ranks
        ActiveRecord::Base.connection.execute <<~SQL.squish
          select sum(score), decidim_project_id  from (
            select dbp.title->'es' as  title, dbli.*, RANK() OVER (
              PARTITION BY dbli.decidim_order_id 
              ORDER BY dbli.id DESC
            ) score
            FROM decidim_budgets_orders dbo
            JOIN decidim_budgets_line_items dbli ON dbo.id = dbli.decidim_order_id 
            join decidim_budgets_projects dbp on dbp.id = dbli.decidim_project_id
            WHERE dbo.decidim_budgets_budget_id  = 3
          ) ranks
          group by decidim_project_id
        SQL
      end

      def count
        @count ||= ranks.find { |r| r["decidim_project_id"] == model.id }["sum"].to_i
      end

      def content
        if options[:layout] == :one_line
          safe_join([count, " ", label(t("decidim.budgets.projects.project.votes",
                                         count: count))])
        else
          safe_join([number, label(t("decidim.budgets.projects.project.votes",
                                     count: count))])
        end
      end

      def number
        content_tag :div, count, class: "text-large"
      end

      def label(i18n_string)
        content_tag :span, i18n_string, class: "text-uppercase text-small"
      end

      def css_class
        css = ["project-votes"]
        css << options[:class] if options[:class]
        css.join(" ")
      end
    end
  end
end
