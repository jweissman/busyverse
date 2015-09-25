Given(/^I am on (.*)$/) do |page|
  visit root_path
end

When(/^I click (.*)$/) do |element|
  puts "--- would be simulating click on #{element}"
  #pending
end

Then(/^I see a new building$/) do
  puts "--- it's a new building"
  #pending
end
