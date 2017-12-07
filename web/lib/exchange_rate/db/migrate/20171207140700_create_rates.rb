class CreateRates < ActiveRecord::Migration[5.0]
	def change
		create_table :rates do |t|
			t.string :date
			t.float :value
			t.belongs_to :currency, :foreign_key => true
			t.timestamps
		end
	end
end