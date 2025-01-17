Given("the following transactions exists:") do |table|
  phone = '12345678' # Replace with the actual phone number for the user
  password = '224466' # Replace with the actual password for the user

  visit sign_up_path
  fill_in 'user_phone', with: phone
  fill_in 'user_password', with: password
  fill_in 'user_password_confirmation', with:password
  click_button 'Sign Up'

  transaction_data = table.hashes.first
  user = User.find_by(phone: phone)

  table.hashes.each do |transaction_data|
    Transaction.create!(
      name: transaction_data['name'],
      amount: transaction_data['amount'].to_d,
      created_at: Time.current,
      updated_at: Time.current,
      user_id: user.id
    )
  end
end

Given("the following scheduled transaction exists:") do |table|
  phone = '12345678' # Replace with the actual phone number for the user
  password = '224466' # Replace with the actual password for the user

  visit sign_up_path
  fill_in 'user_phone', with: phone
  fill_in 'user_password', with: password
  fill_in 'user_password_confirmation', with:password
  click_button 'Sign Up'

  scheduled_transaction_data = table.hashes.first
  user = User.find_by(phone: phone)

  ScheduledTransaction.create!(
    name: scheduled_transaction_data['name'],
    amount: scheduled_transaction_data['amount'].to_d,
    start_date: scheduled_transaction_data['start_date'],
    frequency: scheduled_transaction_data['frequency'],
    created_at: Time.current,
    updated_at: Time.current,
    user_id: user.id
  )
end


Given("that I am on the transactions page") do
  visit transactions_path
end

When("I see suggestions in the carousel") do
  within('.carousel-inner') do
    carousel_items = all('.item')

    suggestions_item = carousel_items.find do |item|
      item.has_css?('.carousel-caption p.textheader', text: 'Suggestion:')
    end

    if suggestions_item
      # Perform your assertions or actions here
      within(suggestions_item) do
        expect(page).to have_css('.carousel-caption p.textheader', text: 'Suggestion:')
        expect(page).to have_content('Based on your frequent transactions')
      end
    else
      raise "No carousel item with suggestion found"
    end
  end
end



And("I click the {string} button") do |button_name|
  click_on(button_name)
end


Then("I should see the new {string} page") do |pay|
  expect(page).to have_content(pay)
end

When("I fill in the recipient name") do
  fill_in('scheduled_transaction_name', with: '12345678') # Adjust the field name based on your HTML
end

And("fill in the amount to be transferred in SGD") do
  fill_in('scheduled_transaction_amount', with: '100') # Adjust the field name based on your HTML
end

And("I fill in the start date with {string}") do |date|
  fill_in 'scheduled_transaction_start_date', with: date
end


And("I can choose the frequency of the scheduled transaction to be {string}") do |option|
  select(option, from: 'scheduled_transaction_frequency')
end

Then('I click the button Save at the bottom') do
  find('#submit-button').click
end

Then('I should see a reminder saying {string}') do |reminder_text|
  expect(page).to have_content(reminder_text)
end

When('I click Yes on the reminder') do
  expect(page).to have_selector('#confirmation-popup', visible: true)
  find('#confirm-yes', visible: true).click
  button = find('#confirm-yes', visible: true)
  button.click
  sleep 10
  puts page.html
end

When("I click on transfers scheduled button") do
  find('button.transparent a[href="/scheduled_transactions"]').click
end

Then("I should see the scheduled payment that I made with the correct name {string}") do |expected_name|
  expect(page).to have_content("Name: #{expected_name}")
end

Then('I should be redirected to the homepage') do
  expect(page).to have_current_path('/transactions', ignore_query: true)
end

Then('I should no longer see the scheduled transaction with the name {string}') do |expected_name|
  expect(page).not_to have_content("Name: #{expected_name}")
end
