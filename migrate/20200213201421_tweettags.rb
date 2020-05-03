class Tweettags < ActiveRecord::Migration[6.0]
  def change
    create_table :tweettags do |t|
      t.integer :tag_id
      t.integer :tweet_id
      t.timestamps
    end
  end
end
