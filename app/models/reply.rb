class Reply < ApplicationRecord
    acts_as_votable
    belongs_to :user
    belongs_to :submission
    belongs_to :comment, optional: true
    belongs_to :parent, :class_name => "Reply", :foreign_key => "reply_parent_id", optional: true
    has_many :child_replies, :class_name => "Reply", :foreign_key => "reply_parent_id"

    validates :content, presence: true
end
