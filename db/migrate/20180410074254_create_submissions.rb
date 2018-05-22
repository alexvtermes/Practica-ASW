class CreateSubmissions < ActiveRecord::Migration[5.1]
  def change
    create_table :submissions do |t|
      t.string :title
      t.string :url
      t.string :text
      t.references :user, foreign_key: true
      t.timestamps
    end
    add_index :submissions, [:user_id]
  end
end
