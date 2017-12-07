class CreateCurrencies < ActiveRecord::Migration
	def change
		say "Created a table"
		create_table :currencies do |t|
			t.string :name, :index => true
			t.timestamps
		end
	end
end