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

      def count
        @count ||= model.confirmed_orders_count

=begin
weights
  SELECT dbli.*, RANK() OVER(
    PARTITION BY dbli.decidim_order_id 
    ORDER BY dbli.id DESC
  ) RANK FROM decidim_budgets_orders dbo
  JOIN decidim_budgets_line_items dbli ON dbo.id = dbli.decidim_order_id 
  WHERE dbo.decidim_budgets_budget_id  = 3
=end

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
