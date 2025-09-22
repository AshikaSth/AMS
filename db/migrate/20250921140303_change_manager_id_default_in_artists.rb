class ChangeManagerIdDefaultInArtists < ActiveRecord::Migration[8.0]
  def change

    change_column_default :artists, :manager_id, nil
    change_column_null :artists, :manager_id, true

  end
end
