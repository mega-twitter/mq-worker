class CreateComments < ActiveRecord::Migration[6.0]
  def change
    create_table :comments do |t|
      t.string :content
      t.integer :comment_user_id
      t.integer :tweet_id

      t.timestamps
    end
  end
end
