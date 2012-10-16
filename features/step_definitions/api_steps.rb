Given /^I POST to "([^"]*)" with:$/ do |path, table|
  # table is a Cucumber::Ast::Table
  interpolate_hash_values! table.rows_hash
  params = table.rows_hash
  post interpolate(path), params
end

Given /I expect a POST to (.*) eventually/ do |endpoint|
  stub_request(:post, interpolate(endpoint)).with { |request| @last_received_request = request }
end

Then /^the response status should be (\d+)$/ do |status|
puts last_response.body
  last_response.status.to_s.should == status.to_s
end

Then /^the JSON response should include:$/ do |json|
  expected_object = JSON.parse(interpolate(json))
  response_object = JSON.parse(last_response.body)
  response_object.should include(expected_object)
end

Then /^the JSON response should include entries:$/ do |table|
  interpolate_hash_values! table.rows_hash
  params = table.rows_hash
  response_object = JSON.parse(last_response.body)
  response_object.should include(params)
end

Then /^the JSON response should include the keys: (.+)$/ do |keys|
  response_object = JSON.parse(last_response.body)
  response_object.should include(*keys.split(/\s*,\s*/))
end

Then /^the JSON response should not include the keys: (.+)$/ do |keys|
  response_object = JSON.parse(last_response.body)
  response_object.should_not include(*keys.split(/\s*,\s*/))
end

Then /^the JSON response should have (\d+) objects?$/ do |size|
  response_object = JSON.parse(last_response.body)
  response_object.length.should == Integer(size)
end

Then 'the JSON errors should include:' do |json|
  expected_errors = JSON.parse(interpolate(json))
  response_object = JSON.parse(last_response.body)
  response_object['errors'].should include(expected_errors)
end

Then /^the JSON response should match \/(.*)\/$/ do |pattern|
  last_response.body.should =~ Regexp.new(pattern)
end

Given /^I GET from "([^"]*)"$/ do |path|
  get interpolate(path)
end

Given /^I GET from "([^"]*)" with:$/ do |path, table|
  interpolate_hash_values! table.rows_hash
  params = table.rows_hash
  get interpolate(path), params
end


Given /^I DELETE "([^"]*)"$/ do |path|
  delete interpolate(path)
end

Given /this feature is not implemented/ do 
  pending
end

