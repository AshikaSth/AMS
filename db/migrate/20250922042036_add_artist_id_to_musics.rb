class AddArtistIdToMusics < ActiveRecord::Migration[8.0]
  def change
    add_column :musics, :artist_id, :bigint
    add_index :musics, :artist_id
  end
end
