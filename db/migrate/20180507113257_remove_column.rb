class AddParentReplyIdToReplies < ActiveRecord::Migration[5.1]
  def change
    #add_column :replies, :parent_reply_id, :string, index: true
    remove_column :replies, :reply_id
  end
end
