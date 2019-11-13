require 'json'
require 'pg'
$evm.root['miq_request'].reload
msg = $evm.root['miq_request'].reason
$evm.log('info', "VISH_DEBUG after admin procedure = #{msg.to_s}")
$evm.log('info', "State before pending= #{$evm.root['miq_request'].approval_state}")

# SETUP TAG APPROVE LEVEL
level=$evm.root['miq_request'].get_tag(:approvestage).to_i
$evm.log('info', "VISH_DEBUG level=#{level}")
if $evm.root['miq_request'].get_tag(:approvestage).to_s == ""
	$evm.root['miq_request'].add_tag(:approvestage,"1")
    level=1

else
  	levelnext=level+1
    $evm.root['miq_request'].clear_tag(:approvestage,level)
    $evm.root['miq_request'].add_tag(:approvestage,levelnext)
end

$evm.root['miq_request'].reload

$evm.log('info', "tag = #{$evm.root['miq_request'].get_tag(:approvestage).to_i}")
if $evm.root['miq_request'].get_tag(:approvestage).to_i == 1
    # Raise automation event: request_pending
    $evm.root["miq_request"].pending
	id=$evm.root['miq_request'].id
	superstr = "update miq_approvals set state='pending' where miq_request_id='#{id}';"
	$evm.log('info', "VISH_DEBUG execute sql = #{superstr}")
	conn = PG.connect(:hostaddr=>'127.0.0.1', :port=>5432, :user=>"#{$evm.object['pguser']}", :password=>"#{$evm.object.decrypt('pgpassword')}", :dbname => 'vmdb_production')
	puts conn.exec(superstr)
end

msg1 = "miq_request get_tag ="
msg1 += "#{$evm.root['miq_request'].get_tag(:approvestage)}"
msg1 += "miq_request get_tags ="
msg1 += "#{$evm.root['miq_request'].get_tags}"
$evm.log('info', "VISH_DEBUG after increment #{msg1}")
