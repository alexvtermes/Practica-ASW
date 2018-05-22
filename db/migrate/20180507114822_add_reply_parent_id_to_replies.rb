class AddReplyParentIdToReplies < ActiveRecord::Migration[5.1]
  def change
    add_column :replies, :reply_parent_id, :integer
  end
end
