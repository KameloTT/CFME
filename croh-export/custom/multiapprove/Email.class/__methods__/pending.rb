require 'pg'
appliance = $evm.root['miq_server'].ipaddress
#Croc specify
appliance = "ccp.hosting.croc.ru:8000"

# Get requester email else set to nil
#requester_email = $evm.root['miq_request'].requester.email || nil


if $evm.root['miq_request'].get_tag(:approvestage).to_s.length == 0
   level=1
   begin
		requesterid=$evm.root['miq_request'].requester_id
		requestername=$evm.root['miq_request'].requester_name
        requesteremail=$evm.root['miq_request'].requester.email
		$evm.root['miq_request'].set_option(:requesterid,requesterid)
		$evm.root['miq_request'].set_option(:requestername,requestername)
        $evm.root['miq_request'].set_option(:requesteremail,requesteremail)
    rescue
        $evm.log('info', "VISH_DEBUG Cannot GET requester INFO------------------------------------------------------------------------")
    end
else
    level=$evm.root['miq_request'].get_tag(:approvestage).to_i+1
end
grpmanager=$evm.object["GroupApproval#{level}"]
#DELEGATE TO FIRST GROUP
$evm.log('info', "VISH_DEBUG grpmanager=#{grpmanager}")
grpobject=$evm.vmdb(:miq_group).find_by_description(grpmanager)
$evm.log('info', "VISH_DEBUG grpobject=#{grpobject}")
user=grpobject.users.first
id=$evm.root['miq_request'].id
superstr = "update miq_requests set userid='#{user.name}',requester_id='#{user.id}' where id='#{id}';"
$evm.log('info', "VISH_DEBUG execute sql = #{superstr}")
conn = PG.connect(:hostaddr=>'127.0.0.1', :port=>5432, :user=>"#{$evm.object['pguser']}", :password=>"#{$evm.object.decrypt('pgpassword')}", :dbname => 'vmdb_production')
puts conn.exec(superstr)
$evm.log('info', "VISH_DEBUG DELEGATE TASK TO user.name=#{user.name}")
$evm.log('info', "VISH_DEBUG DELEGATE TASK TO user.id=#{user.id}")


# SEND EMAIL
$evm.log('info', "Level:#{level} Approve email logic starting")
# Get appliance IP
@dialog_options_hash = $evm.root['miq_request'].options[:dialog]
to = user.email
requester_email = $evm.root['miq_request'].get_option(:requesteremail)
$evm.log('info', "VISH_DEBUG user.email (sent message to first approver)=#{user.email}")
#to ||= $evm.object['to_email_address']

# Get from_email_address from model unless specified below
from = nil
from ||= $evm.object['from_email_address']

# Get signature from model unless specified below
signature = nil
signature ||= $evm.object['signature']

# Build subject
subject = "Request ID #{$evm.root['miq_request'].id} - Service request needs approving"

body = "<br>"
body += "<br>A Service request received from #{requester_email} is pending, and you are the #{level} level approver."
body += "<br><br>Request details: "
if @dialog_options_hash.key?('dialog_service_name')
  body += "<br><br>&nbsp;&nbsp;Service description: #{@dialog_options_hash['dialog_service_name']}"
else
  body += "<br><br>&nbsp;&nbsp;Service description: #{$evm.root['miq_request'].description}"
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

body += "<br><br>&nbsp;&nbsp;Service tags selected: "

#dialog_tags(@dialog_options_hash).each do |option|
#    key, value = option.flatten
#    body += "<br>&nbsp;&nbsp;&nbsp;&nbsp;#{key}: #{value}"
#end

body += "<br><br>To approve or deny this request please go to: "
body += "<a href='https://#{appliance}/miq_request/show/#{$evm.root['miq_request'].id}'>https://#{appliance}/miq_request/show/#{$evm.root['miq_request'].id}</a>"
body += "<br><br> Thank you,"
body += "<br> #{signature}"

# Send email
$evm.log("info", "Sending email to <#{to}> from <#{from}> subject: <#{subject}>")
$evm.execute(:send_email, to, from, subject, body)
