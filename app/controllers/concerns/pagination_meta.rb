# frozen_string_literal: true

module PaginationMeta
  def pagination_dict(page, per_page, total)
    total_pages = (total.to_f / per_page).ceil
    prev_page = page - 1
    prev_page = 1 if prev_page < 1
    next_page = page + 1
    next_page = total_pages if next_page > total_pages
    {
      current_page: page,
      next_page: next_page,
      prev_page: prev_page, # use collection.previous_page when using will_paginate
      total_pages: total_pages,
      total_count: total
    }
  end
end
