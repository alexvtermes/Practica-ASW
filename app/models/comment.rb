class Comment < ApplicationRecord
  acts_as_votable
  belongs_to :user
  belongs_to :submission
  has_many :reply
    
  validates :content, presence: true
end  