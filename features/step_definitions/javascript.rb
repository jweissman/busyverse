Then(/^I see no javascript errors$/) do
  # expect(page).not_to have_errors
  errors = page.driver.error_messages
  puts "Errors: #{errors}"
  expect(errors).to be_empty
end
