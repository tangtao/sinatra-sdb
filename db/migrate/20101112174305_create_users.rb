class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|

      t.string :email, :limit => 100
      t.string :hashed_password, :limit => 100
      t.string :salt, :limit => 100
      t.boolean :is_admin, :default => true
      t.string :key,        :limit => 64
      t.string :secret,     :limit => 64
      
      t.timestamps
    end

    add_index :users, :email,                :unique => true
  end

  def self.down
    drop_table :users
  end

end
