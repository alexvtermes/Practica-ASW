class CreateReplies < ActiveRecord::Migration[5.1]
  def change
    create_table :replies do |t|
      t.text :content
      t.integer :user_id
      t.integer :comment_id
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps
    end
  end
end
