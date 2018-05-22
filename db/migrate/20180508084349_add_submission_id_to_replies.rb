class AddSubmissionIdToReplies < ActiveRecord::Migration[5.1]
  def change
    add_column :replies, :submission_id, :integer
  end
end
