appliance = $evm.root['miq_server'].ipaddress
#Croc specify
appliance = "ccp.hosting.croc.ru:8000"
miq_request=$evm.root['miq_request']
if miq_request.get_tag(:approvestage).to_s.length == 0
   level=1
else
    level=miq_request.get_tag(:approvestage).to_i
end
maxlevel=2
$evm.log('info', "Next Approve email logic starting")
# Get appliance IP
@dialog_options_hash = miq_request.options[:dialog]
# Get requester email else set to nil
requester_email = $evm.root['miq_request'].get_option(:requesteremail)

# If to is still nil use to_email_address from model
to = nil
#to ||= $evm.object['to_email_address']
to ||= miq_request.get_option(:requesteremail)
to ||= miq_request.requester.email
# Get from_email_address from model unless specified below
from = nil
from ||= $evm.object['from_email_address']

# Get signature from model unless specified below
signature = nil
signature ||= $evm.object['signature']

# Build subject
subject = "Request ID #{miq_request.id} - Your Service provision request has #{level} approve"

body = "Hello, "
body += "<br>Your Service with email(#{requester_email}) provision request was approved by the #{level} approver."
body += "<br><br>Approvers notes: #{miq_request.reason}"
if level==maxlevel
	body += "<br>If Service provisioning is successful you will be notified via email when the Service is available."
    finalbody = "<br><br>To view this Request go to: <a href='https://#{appliance}/miq_request/show/#{miq_request.id}'>https://#{appliance}/miq_request/show/#{miq_request.id}</a>"
else
	body += "<br>Please wait answer from next approver."
    finalbody=""
end

#body = "<br>"
#body += "<br>A Service request received from #{requester_email} is approved, and you are the next stage approver."
body += "<br><br>Request details: "
if @dialog_options_hash.key?('dialog_service_name')
  body += "<br><br>&nbsp;&nbsp;Service description: #{@dialog_options_hash['dialog_service_name']}"
else
  body += "<br><br>&nbsp;&nbsp;Service description: #{miq_request.description}"
end
  body += "<br><br>&nbsp;&nbsp;Service options selected: "

def dialog_options(options_hash)
  options = []
  options_hash.each do |option, value|
    next if /(^tag|^dialog_tag|^.*guid.*$).*/ =~ option
    options << {option.to_s.sub(/^dialog_option_\d+_/, '').sub(/^dialog_/, '') => value}
  end
  options
end

dialog_options(@dialog_options_hash).each do |option| 
  key, value = option.flatten
  body += "<br>&nbsp;&nbsp;&nbsp;&nbsp;#{key}: #{value}"
end

body += finalbody
body += "<br><br> Thank you,"
body += "<br> #{signature}"

# Send email
$evm.log("info", "Sending email to <#{to}> from <#{from}> subject: <#{subject}>")
$evm.execute(:send_email, to, from, subject, body)
