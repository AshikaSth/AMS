class CreateArtistMusics < ActiveRecord::Migration[8.0]
  def change
    create_table :artist_musics do |t|
      t.references :artist, null: false, foreign_key: true
      t.references :music, null: false, foreign_key: true

      t.timestamps
    end
  end
end
