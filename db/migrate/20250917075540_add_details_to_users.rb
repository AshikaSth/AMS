class AddDetailsToUsers < ActiveRecord::Migration[8.0]
  def change
    change_column :users, :role, :integer, using: 'role::integer', default: 2

    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :phone_number, :string
    add_column :users, :gender, :integer, default: 0
    add_column :users, :address, :string
    add_column :users, :dob, :date
  end
end