# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
puts 'Create 4 questions'
questions = FactoryBot.create_list :question, 4

puts 'Create 4 answers'
answers = FactoryBot.create_list :answer, 4

puts 'Create 4 users'
user = FactoryBot.create_list :user, 4

