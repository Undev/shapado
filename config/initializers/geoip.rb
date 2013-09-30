
file = File.join(Rails.root.to_s, "data", "GeoLiteCity.dat")

if File.exist?(file)
  Localize = GeoIP.new(file)
else
  puts 'Missing GeoIP data'
end


