class CreateTables < Sequel::Migration
  def up
    create_table(:agenda) do
      primary_key :id
      
      String      :description, :null => false, 
    end
    
    create_table(:blocks) do
      primary_key :id
     
      varchar     :title, :size => 80
      longtext    :content
      
      foreign_key :parent, :table => :blocks, :key => :id, :on_delete => :cascade 
      index       :parent
    end
    
    create_table(:categories) do
      primary_key :id
      
      varchar     :description, :size => 20
    end
    
    create_table(:comments) do
      primary_key :id
      
      longtext    :content
      DateTime    :created_at, :default => :CURRENT_TIMESTAMP
      
      foreign_key :parent, :table => :comments, :key => :id, :on_delete => :cascade 
      foreign_key :user_id, :table => :users, :key => :id, :on_delete => :cascade 
      index       :parent
      index       :user_id
    end
    
    create_table(:albums) do
      primary_key :id
      
      varchar     :title, :size => 60
      
      foreign_key :user_id, :table => :users, :key => :id, :on_delete => :cascade 
      foreign_key :category_id, :table => :categories, :key => :id, :on_delete => :cascade 
    end
    
    create_table(:band_elements) do
      foreign_key :user_id, :table => :users, :key => :id, :on_delete => :cascade 
      foreign_key :element_id, :table => :users, :key => :id, :on_delete => :cascade
    end
    
    create_table(:events) do
      primary_key :id
      
      varchar     :name, :size => 80
      longtext    :description
        
      foreign_key :map_point_id, :table => :map_points, :key => :id, :on_delete => :cascade
      foreign_key :agenda_id, :table => :agenda, :key => :id, :on_delete => :cascade
    end
    
    create_table(:map_points) do
      primary_key :id
     
      Float     :latitude
      Float     :longitude
      varchar   :name, :size => 80
      longtext  :description
    end
    
    create_table(:mailing_list_messages) do
      primary_key :id
      
      DateTime    :created_at, :default => :CURRENT_TIMESTAMP
      longtext    :content
      
      foreign_key :mailing_list_id, :table => :mailing_list, :key => :id, :on_delete => :cascade 
    end
    
    create_table(:mailing_list) do
      primary_key :id
      
      TrueClass   :state
    end
    
    create_table(:tracks) do
      primary_key :id
      
      varchar     :title, :size => 60
      smallint    :number
      text        :lyrics
      varchar     :path, :size => 60
      
      foreign_key :album_id, :table => :albums, :key => :id, :on_delete => :cascade 
    end
    
    create_table(:countries) do
      primary_key :id
    
      varchar     :abbr, :size => 3
      varchar     :country, :size => 30
    end
    
    create_table(:profiles) do
      primary_key :id
     
      String      :address
      varchar     :province, :size => 30
      varchar     :zip_code, :size => 10
      varchar     :city, :size => 30
      String      :real_name
      varchar     :photo_path, :size => 60
      text        :preferences
      
      foreign_key :country_id, :table => :countries, :key => :id, :on_delete => :cascade 
      foreign_key :map_point_id, :table => :map_points, :key => :id, :on_delete => :cascade
    end
    
    create_table(:users) do
      primary_key :id
  
      varchar     :email, :size => 100, :unique => true
      varchar     :password, :size => 128
      
      foreign_key :agenda_id, :table => :agenda, :key => :id, :on_delete => :cascade 
      foreign_key :mailing_list_id, :table => :mailing_lists, :key => :id, :on_delete => :cascade 
      foreign_key :profile_id, :table => :profiles, :key => :id, :on_delete => :cascade 
    end
    
    create_table(:users_favs) do
      foreign_key :band_id, :table => :users, :key => :id, :on_delete => :cascade 
      foreign_key :user_id, :table => :users, :key => :id, :on_delete => :cascade 
    end
    
    create_table(:users_mailing_lists) do
      foreign_key :mailing_list_id, :table => :mailing_lists, :key => :id, :on_delete => :cascade 
      foreign_key :user_id, :table => :users, :key => :id, :on_delete => :cascade 
    end
  end
  
  def down
    drop_table :agenda
    drop_table :blocks
    drop_table :categories
    drop_table :comments
    drop_table :albums
    drop_table :band_elements
    drop_table :events
    drop_table :map_points
    drop_table :mailing_list_messages
    drop_table :mailing_lists
    drop_table :tracks
    drop_table :countries
    drop_table :profiles
    drop_table :users
    drop_table :users_favs
    drop_table :users_mailing_lists
  end
end
