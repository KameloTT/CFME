require 'json'
require 'pg'
require 'rest-client'
vm_name = $evm.root['dialog_vm_name'].to_s
service_name = $evm.root['service'].name

getid = "select id from vms where name='#{vm_name}';"

conn = PG.connect(:hostaddr=>'127.0.0.1', :port=>5432, :user=>'root', :password=>'P@ssw0rd', :dbname => 'vmdb_production')
puts vmid = conn.exec(getid)
id = vmid.getvalue(0,0)

options = {
  :method       => :get,
  :url          => "https://admin:P%40ssw0rd@172.24.17.73/api/vms/#{id}?expand=resources&attributes=name,ipaddresses/",
  :headers      => {:content_type=>'application/json'},
  :verify_ssl  => false,
}
resource = RestClient::Request.new(options).execute
response = JSON.parse(resource)
ipadr = response["ipaddresses"][0]

if service_name.include?("Web") 
  superstr = "update services set description='Service: http://#{ipadr} VMNAME:#{vm_name}' where name='#{service_name}';"
elsif service_name.include?("Rabbitmq")
  superstr = "update services set description='Services: http://#{ipadr} amqp://AMQP:#{ipadr} VMNAME:#{vm_name}' where name='#{service_name}';"
else
  superstr = "update services set description='Services: IP:#{ipadr} VMNAME:#{vm_name}' where name='#{service_name}';"
end
conn = PG.connect(:hostaddr=>'127.0.0.1', :port=>5432, :user=>'root', :password=>'P@ssw0rd', :dbname => 'vmdb_production')
puts conn.exec(superstr)
