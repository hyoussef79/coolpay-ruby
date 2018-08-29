require './autoload'

# This is a hardcoded run example
# in real production system I'd model recipients & payments
# and encapsulate its data and logic in classes/objects
#
# The following example will 'Authenticate to Coolpay API', 'Add a recipient', 'Send him money' & 'Check payment status'.
# To execute, run: COOLPAY_USERNAME=username COOLPAY_APIKEY=apikey ruby run.rb
username = ENV.fetch('COOLPAY_USERNAME', '')
apikey = ENV.fetch('COOLPAY_APIKEY', '')
client = Client::CoolPayApi.new(username, apikey)

puts 'Creating a recipient with name: Hesham'
recipient = client.create_recipient({ recipient: { name: 'Hesham' } })
puts 'Recipient with name: Hesham has been created'

puts 'Sending a payment to Hesham'
payment = client.create_payment({
  payment: {
    amount: 10.50,
    currency: 'GBP',
    recipient_id: recipient['id']
  }
})

while payment['status'] != 'paid'
  payment = client.payments.find do |p|
    p['id'] == payment['id']
  end

  case payment['status']
  when 'failed'
    puts 'Your payment failed!'
    break
  when 'processing'
    puts 'not paid yet, still processing'
  end
end

puts 'Your payment has been processed!' if payment['status'] == 'paid'
