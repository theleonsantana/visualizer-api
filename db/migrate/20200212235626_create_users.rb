class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|

      t.string :name
      t.string :user_image
      t.string :country
      t.string :user_spotify_url
      t.string :user_spotify_id
      t.string :access_token
      t.string :refresh_token

      t.timestamps
    end
  end
end
