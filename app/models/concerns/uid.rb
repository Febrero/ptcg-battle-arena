module Uid
  extend ActiveSupport::Concern

  included do
    field :uid, type: Integer
    before_create :set_uid
    index({uid: 1}, {name: "uid_index", background: true})
  end

  # Define the method to be called after create
  def set_uid
    # Your reusable logic here
    # puts "Reusable after_create logic here."
    self.uid = (self.class.max(:uid) || 0) + 1 if respond_to?(:uid)
  end
end
