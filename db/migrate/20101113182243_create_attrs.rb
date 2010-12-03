class CreateAttrs < ActiveRecord::Migration
  def self.up
    create_table(:attrs) do |t|

      t.references :item
      t.string :name,  :limit => 100
      t.text :content
      t.string :md5sum, :limit => 32
      
      t.timestamps
    end
  end

  def self.down
    drop_table :attrs
  end

end
