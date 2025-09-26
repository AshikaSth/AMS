class CreateArtists < ActiveRecord::Migration[8.0]
  def change
    create_table :artists do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :first_release_year
      t.text :bio
      t.string :website
      t.string :photo_url
      t.string :genres
      t.jsonb :social_media_links

      t.timestamps
    end
  end
end
