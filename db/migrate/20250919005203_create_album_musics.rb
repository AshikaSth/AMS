class CreateAlbumMusics < ActiveRecord::Migration[8.0]
  def change
    create_table :album_musics do |t|
      t.references :album, null: false, foreign_key: true
      t.references :music, null: false, foreign_key: true

      t.timestamps
    end
  end
end
