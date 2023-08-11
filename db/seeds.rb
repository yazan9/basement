# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# db/seeds.rb

require 'securerandom'

def random_location(lat, lon, max_radius_km)
  # Convert latitude and longitude from degrees to radians.
  lat_rad = lat * Math::PI / 180
  lon_rad = lon * Math::PI / 180

  # Generate a random distance and angle.
  random_distance = SecureRandom.random_number(max_radius_km)
  random_angle = SecureRandom.random_number(2 * Math::PI)

  # Calculate the random offsets for the latitude and longitude.
  delta_lat = random_distance / 6371.0 * Math.sin(random_angle)
  delta_lon = random_distance / (6371.0 * Math.cos(lat_rad)) * Math.cos(random_angle)

  # Convert the offsets from radians to degrees.
  lat_offset = delta_lat * 180 / Math::PI
  lon_offset = delta_lon * 180 / Math::PI

  # Apply the offsets to get the random location.
  new_lat = lat + lat_offset
  new_lon = lon + lon_offset

  [new_lat, new_lon]
end

def seed_100_providers
  # Center point, Victoria, BC
  center_lat = 48.4322105
  center_lon = -123.3693218

  # Seed 100 users
  100.times do |i|
    email = "user#{i}@example.io"
    password = 'password123'
    name = "User #{i}"
    phone = "12345#{i.to_s.rjust(4, '0')}"
    user_type = 'provider'

    lat, lon = random_location(center_lat, center_lon, 50)

    user = User.new(email: email, password: password, name: name, phone: phone, user_type: user_type)
    user.location = "POINT(#{lon} #{lat})"
    user.save!
  end

  puts "Seeded 100 users of type: provider !"
end

seed_100_providers


