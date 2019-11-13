require 'pg'
$evm.root['miq_request'].reload
#exit MIQ_OK
userid=$evm.root['miq_request'].get_option(:requesterid)
username=$evm.root['miq_request'].get_option(:requestername)
useremail=$evm.root['miq_request'].get_option(:requesteremail)
id=$evm.root['miq_request'].id
superstr = "update miq_requests set userid='#{username}',requester_id='#{userid}' where id='#{id}';"
$evm.log('info', "VISH_DEBUG execute sql = #{superstr}")
conn = PG.connect(:hostaddr=>'127.0.0.1', :port=>5432, :user=>"#{$evm.object['pguser']}", :password=>"#{$evm.object.decrypt('pgpassword')}", :dbname => 'vmdb_production')
puts conn.exec(superstr)
$evm.log('info', "VISH_DEBUG RETURN TASK TO username=#{username}")
$evm.log('info', "VISH_DEBUG RETURN TASK TO userid=#{userid}")
$evm.log('info', "VISH_DEBUG RETURN TASK TO useremail=#{useremail}")
