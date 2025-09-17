class CreateMusics < ActiveRecord::Migration[8.0]
  def change
    create_table :musics do |t|
      t.string :title
      t.string :genre
      t.references :artist, null: false, foreign_key: true
      t.references :album, null: false, foreign_key: true
      t.string :audio_file_url
      t.string :cover_art_url

      t.timestamps
    end
  end
end
