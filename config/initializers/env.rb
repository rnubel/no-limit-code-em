ENV['NLCE_ACTIVE'] ||= "1"

if Rails.env.production?
  ENV['NLCE_ACTIVE'] = "0" # Turned off until we go live, baby.
end
