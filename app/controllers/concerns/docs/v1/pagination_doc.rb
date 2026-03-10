module Docs
  module V1
    module PaginationDoc
      extend Apipie::DSL::Concern

      def_param_group :pagination do
        param :"current-page", Integer, desc: "Current page"
        param :"next-page", Integer, desc: "Next page"
        param :"prev-page", Integer, desc: "Previous page"
        param :"total-pages", Integer, desc: "Total pages"
        param :"total-count", Integer, desc: "Total count of items"
      end
    end
  end
end
