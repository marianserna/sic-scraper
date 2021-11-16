class CreateResolutions < ActiveRecord::Migration[6.1]
  def change
    create_table :resolutions do |t|
      t.string :company, null: false
      t.date :date, null: false
      t.text :overview, null: false
      t.string :pdf_url, null: false
      t.timestamp :extracted_at
      t.text :context
      t.text :decision
      t.timestamps

      t.index :pdf_url, unique: true
    end
  end
end
