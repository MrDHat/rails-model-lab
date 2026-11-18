class CreateGazetteTables < ActiveRecord::Migration[8.1]
  def change
    create_table :sections do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.timestamps
    end
    add_index :sections, :slug, unique: true

    create_table :authors do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :role
      t.text :bio
      t.timestamps
    end
    add_index :authors, :email, unique: true

    create_table :editors do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :access_code, null: false
      t.boolean :chief, null: false, default: false
      t.references :author, foreign_key: true
      t.timestamps
    end
    add_index :editors, :email, unique: true

    create_table :articles do |t|
      t.references :section, null: false, foreign_key: true
      t.string :headline, null: false
      t.string :slug, null: false
      t.string :dek
      t.text :body, null: false, default: ""
      t.integer :status, null: false, default: 0
      t.datetime :publish_at
      t.datetime :published_at
      t.integer :views_count, null: false, default: 0
      t.integer :comments_count, null: false, default: 0
      t.boolean :comments_enabled, null: false, default: true
      t.string :wire_guid
      t.timestamps
    end
    add_index :articles, :slug, unique: true
    add_index :articles, :wire_guid, unique: true
    add_index :articles, %i[status published_at]
    add_index :articles, :updated_at

    create_table :authorships do |t|
      t.references :article, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: true
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :authorships, %i[article_id author_id], unique: true

    create_table :tags do |t|
      t.string :name, null: false
      t.timestamps
    end
    add_index :tags, :name, unique: true

    create_table :taggings do |t|
      t.references :article, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true
      t.timestamps
    end
    add_index :taggings, %i[article_id tag_id], unique: true

    create_table :readers do |t|
      t.string :email, null: false
      t.string :display_name, null: false
      t.string :api_token, null: false
      t.boolean :briefing, null: false, default: false
      t.timestamps
    end
    add_index :readers, :email, unique: true
    add_index :readers, :api_token, unique: true

    # Readers' comments and letters outlive nothing: they go when the reader
    # does, so there is no foreign key to the readers table.
    create_table :comments do |t|
      t.references :article, null: false, foreign_key: true
      t.references :reader, null: false
      t.text :body, null: false
      t.integer :status, null: false, default: 0
      t.timestamps
    end

    create_table :letters do |t|
      t.references :reader
      t.string :name, null: false
      t.string :email, null: false
      t.string :town
      t.string :subject, null: false
      t.text :body, null: false
      t.integer :status, null: false, default: 0
      t.timestamps
    end

    create_table :corrections do |t|
      t.references :article, null: false, foreign_key: true
      t.references :editor, null: false, foreign_key: true
      t.text :body, null: false
      t.timestamps
    end

    create_table :settings do |t|
      t.string :key, null: false
      t.json :value
      t.timestamps
    end
    add_index :settings, :key, unique: true

    create_table :wire_imports do |t|
      t.datetime :received_at, null: false
      t.integer :items_count, null: false, default: 0
      t.integer :created_count, null: false, default: 0
      t.integer :skipped_count, null: false, default: 0
      t.integer :failed_count, null: false, default: 0
      t.timestamps
    end
  end
end
