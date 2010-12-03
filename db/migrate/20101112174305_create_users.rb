class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|

      t.string :login, :limit => 40
      t.string :name,  :limit => 100, :default => '', :null => true
      t.string :email, :limit => 100
      t.string :state, :limit => 32, :null => :false, :default => 'passive'
      
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
