class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.references :parent
      t.references :sender
      t.references :recipient
      t.string :subject
      t.text :body
      t.boolean :unread, :default => true, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
