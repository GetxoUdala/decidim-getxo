# frozen_string_literal: true

module LayoutHelperOverride
  def extended_navigation_bar(items, max_items: 6)
    return unless items.any?

    extra_items = items.slice((max_items + 1)..-1) || []
    active_item = items.find { |item| item[:active] }

    controller.view_context.render partial: "decidim/shared/extended_navigation_bar", locals: {
      items: items,
      extra_items: extra_items,
      active_item: active_item,
      max_items: max_items
    }
  end
end
