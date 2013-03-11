class StartingPositions < ActiveRecord::Migration
  def up
    create_table :projects do |t|
      t.string  :name, :limit => 256, :null => false
      t.text    :readme
      t.date    :date
      t.string  :slug, :limit => 128
    end
    
    create_table :repositories do |t|
      t.string  :name, :limit => 256, :null => false
      t.string  :url, :limit => 256
      t.text    :notes
      t.integer :project_id
    end
    
    create_table :live_sites do |t|
      t.string  :url, :limit => 256, :null => false
      t.text    :notes
      t.integer :project_id
    end
  end
  
  def down
    drop_table :live_sites
    drop_table :repositories
    drop_table :projects
  end
end