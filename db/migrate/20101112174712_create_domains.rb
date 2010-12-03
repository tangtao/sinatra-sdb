class CreateDomains < ActiveRecord::Migration
  def self.up
    create_table(:domains) do |t|

      t.references :user
      t.string :name,  :limit => 100
      
      t.timestamps
    end

    add_index :domains, [:user_id, :name], :unique => true
  end

  def self.down
    drop_table :domains
  end

end
