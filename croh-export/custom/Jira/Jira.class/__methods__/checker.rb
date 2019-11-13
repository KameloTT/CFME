#
# Description: <Method description here>
#
require 'rubygems'
require 'rest-client'
require 'pg'
vm_name = $evm.root['dialog_vm_name'].to_s
getid = "select id from vms where name='#{vm_name}';"
conn = PGconn.open(:hostaddr=>'127.0.0.1', :port=>5432, :user=>'root', :password=>'P@ssw0rd', :dbname => 'vmdb_production')
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

ENV['http_proxy'] = 'http://172.24.17.200:3128/'
ENV['https_proxy'] = 'http://172.24.17.200:3128/'
$evm.log(:info, '------------------------------')
$evm.log(:info, ipadr)
$evm.log(:info, '------------------------------')
options = {
  :method       => :post,
  :url          => "https://#{$evm.object['username']}:#{$evm.object.decrypt('password')}@jira.croc.ru/rest/api/2/issue/",
  :headers      => {:content_type=>'application/json'},
#  :verify_ssl  => false,
  :payload      => {
        :fields => {
        :project => {:key => 'OPENSTACK'},
        :parent => {:key => 'OPENSTACK-786'},
        :summary => "processed #{$evm.root['service'].name} with IP #{ipadr}",
        :description => "processed #{$evm.root['service'].name} with #{$evm.root['dialog_vm_name']}  IP: #{ipadr}",
        :issuetype => {:id => '5'},
        },
        }.to_json,
}
RestClient::Request.new(options).execute
