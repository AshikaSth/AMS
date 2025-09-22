class AddManagerToArtists < ActiveRecord::Migration[8.0]
  def change
    add_reference :artists, :manager, null: false, foreign_key: { to_table: :users }, default: 1
  end
end
