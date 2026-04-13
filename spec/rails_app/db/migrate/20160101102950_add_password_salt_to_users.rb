class AddPasswordSaltToUsers < (Rails::VERSION::MAJOR >= 5 ? ActiveRecord::Migration[4.2] : ActiveRecord::Migration)
  def change
    add_column :users, :password_salt, :string
  end
end
