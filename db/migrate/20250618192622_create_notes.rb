class CreateNotes < ActiveRecord::Migration[7.2]
  def change
    create_table :notes do |t|
      t.string :title, default: ""
      t.text :body, default: ""
      t.boolean :archived, default: false

      t.timestamps
    end
  end
end
