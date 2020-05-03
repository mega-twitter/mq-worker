class AddIndexToTweettagTable < ActiveRecord::Migration[6.0]
  def change
    add_index :tweettags, [:tag_id, :tweet_id], unique: true
  end
end
