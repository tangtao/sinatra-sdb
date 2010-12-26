class CreateItems < ActiveRecord::Migration
  def self.up
    create_table(:items) do |t|

      t.references :domain
      t.string :name,  :limit => 100
      t.text :meta
      
      t.timestamps
    end
    add_index :items, [:domain_id, :name], :unique => true
  end

  def self.down
    drop_table :items
  end

end
