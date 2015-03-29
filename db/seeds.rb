# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# user = CreateAdminService.new.call
# puts 'CREATED ADMIN USER: ' << user.email

Product.create(title: 'Individual Membership', price: 25, stock: 1, first_category: "membership")
Product.create(title: 'Startup Membership', price: 10000, stock: 1, first_category: "membership")
Product.create(title: 'Corporate Membership', price: 50000, stock: 1,first_category: "membership")
Product.create(title: "Bitcoin, mode d'emploi", price: 499, stock: 1,first_category: "ebook")
Product.create(title: 'Bitcoin Book', price: 1499, stock: 1,first_category: "paperback")
