class AddArtistIdAlbums < ActiveRecord::Migration[8.0]
  def change
    add_column :albums, :artist_id, :bigint
    add_index :albums, :artist_id
  end
end
