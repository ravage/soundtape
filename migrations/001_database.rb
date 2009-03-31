class CreateTables < Sequel::Migration
  def up
    create_table(:agenda) do
      primary_key :id
      String :description
    end
    
    create_table(:blocks) do
      primary_key :id
      varchar :title, :size => 80
      longtext :content
      foreign_key :parent, :blocks, :key => :id
      index :parent
    end
    
    create_table(:categories) do
      primary_key :id
      varchar :description, :size => 20
    end
    
    create_table(:comments) do
      primary_key :id
      longtext :content
      DateTime :created_at, :default => :CURRENT_TIMESTAMP
      foreign_key :parent, :comments, :key => :id
      foreign_key :user_id, :users, :key => :id
      index :parent
      index :user_id
    end
    
    create_table(:albums) do
      primary_key :id
      varchar :title, :size => 60
      foreign_key :user_id, :users, :key => :id
      foreign_key :category_id, :categories, :key => :id
    end
    
    create_table(:band_elements) do
      foreign_key :user_id, :users, :key => :id
      foreign_key :element_id, :users, :key => :id
    end
    
    create_table(:events) do
      primary_key :id
      foreign_key :map_point_id, :map_points, :key => :id
      foreign_key :agenda_id, :agenda, :key => :id
      varchar :name, :size => 80
      longtext :description
    end
    
    create_table(:map_points) do
      primary_key :id
      Float :latitude
      Float :longitude
      varchar :name, :size => 80
      longtext :description
    end
    
    create_table(:mailing_list_messages) do
      primary_key :id
      DateTime :created_at, :default => :CURRENT_TIMESTAMP
      foreign_key :mailing_list_id, :mailing_list, :key => :id
      longtext :content
    end
    
    create_table(:mailing_list) do
      primary_key :id
      TrueClass :state
    end
    
    create_table(:tracks) do
      primary_key :id
      foreign_key :album_id, :albums, :key => :id
      varchar :title, :size => 60
      smallint :number
      text :lyrics
      varchar :path, :size => 60
    end
    
    create_table(:countries) do
      primary_key :id
      varchar :abbr, :size => 3
      varchar :country, :size => 30
    end
    
    create_table(:profiles) do
      primary_key :id
      foreign_key :country_id, :countries, :key => :id
      foreign_key :map_point_id, :map_points, :key => :id
      String :address
      varchar :province, :size => 30
      varchar :zip_code, :size => 10
      varchar :city, :size => 30
      String :real_name
      varchar :photo_path, :size => 60
      text :preferences
    end
    
    create_table(:users) do
      primary_key :id
      foreign_key :mailing_list_id, :mailing_lists, :key => :id
      foreign_key :profile_id, :profiles, :key => :id
      varchar :email, :size => 100, :unique => true
      varchar :password, :size => 128
      foreign_key :agenda_id, :agenda, :key => :id
    end
    
    create_table(:users_favs) do
      foreign_key :band_id, :users, :key => :id
      foreign_key :user_id, :users, :key => :id
    end
    
    create_table(:users_mailing_lists) do
      foreign_key :mailing_list_id, :mailing_lists, :key => :id
      foreign_key :user_id, :users, :key => :id
    end
  end
end
