# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

admin_user = Spotlight::Site.first.roles.where(role: 'admin').first.user

if admin_user.present?
  exhibit = Spotlight::Exhibit.find_or_create_by(title: 'Michigan Digital Library Portal',
                                                 slug: 'default',
                                                 published: true,
                                                 site: Spotlight::Site.first
  )

  Spotlight::Role.find_or_create_by(user: admin_user, role: 'admin', resource_id: exhibit.id, resource_type: 'Spotlight::Exhibit')
else
  puts 'Create an admin user first: rake spotlight:initialize'
end

