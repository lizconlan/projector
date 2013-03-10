class CreateUserTable < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.timestamps
      t.string    :login, :null => false
      t.string    :password_digest
      t.string    :persistence_token, :default => "", :null => false
    end
    
    add_index :users, :login
  end

  def self.down
    drop_table :users
  end
end