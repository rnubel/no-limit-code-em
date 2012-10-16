module CucumberHelpers
  class << self
    attr_accessor :bcrypted_password_salt
  end
  # Hacky but useful string interpolation for dynamic values in cucumber steps.
  #
  # Assume:
  #
  #     Given I GET "/accounts/{{@account_id}}"
  #
  # If you implement the step as:
  #
  #     Given /^I GET "(.+)"$/ do |url|
  #       url = interpolate(url)
  #       # ...
  #     end
  #
  # Then `url` will have the returned value from having evaluated the
  # code between the delimiters.
  def interpolate(string)
    string.gsub(/\{\{(.+?)\}\}/) { eval($1) }
  end

  def interpolate_hash_values!(hash)
    hash.each_value { |value| value.replace(interpolate value) }
  end
end

World(CucumberHelpers)
