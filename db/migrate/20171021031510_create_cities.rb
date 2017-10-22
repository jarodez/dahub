class CreateCities < ActiveRecord::Migration[5.1]
  def change
    create_table :cities do |t|
      t.string :name, limit: 20
      t.string :district, limit: 20
      t.string :hall, limit: 20
      t.string :population, limit: 3
      t.references :country, foreign_key: true

      t.timestamps
    end
  end
end
