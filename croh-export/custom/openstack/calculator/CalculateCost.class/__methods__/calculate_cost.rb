# Author: Brant Evans (bevans@redhat.com)
#
# License: GPL v3
#
# Description: Calculate the cost of a VM
#

def dump_root()
  $evm.log(:info, "Begin $evm.root.attributes")
  $evm.root.attributes.sort.each { |k, v| $evm.log(:info, "\t Attribute: #{k} = #{v}")}
  $evm.log(:info, "End $evm.root.attributes")
  $evm.log(:info, "")
end

dialog_field = $evm.object['dialog_vmemory2']
$evm.log(:info, " VISH_DEBUG1: #{dialog_field}")
#$evm.log(:info, " VISH_DEBUG2: #{dialog_field['values']}")
debug = true                                           # enable/disable debug logging in evm.log

cpu_price = $evm.object['cpu_price']                   # get os price per CPU from the instance
mem_price = $evm.object['mem_price']                   # get size price per GB from the instance
storage_price = $evm.object['storage_price']           # get storage price per GB from the instance

# Dump the attributes of $evm.root
dump_root if debug

$evm.log(:info, "********************** CALCULATE PRICING METHOD STARTED **********************") if debug
$evm.log(:info, "VMDB Object Type: #{$evm.root['vmdb_object_type']}") if debug

# Get the field values from the service dialog
# All values need to be converted to integers to use in the calculation
case $evm.root['vmdb_object_type']
when 'service_template'
  cpu_count = $evm.root['dialog_cpus'].to_i
  # memory sizes are in MB so need to convert to GB
  mem_size = ($evm.root['dialog_vmemory'].to_i / 1073741824)
  storage_size = ($evm.root['dialog_disk'].to_i / 1073741824)
end

#$evm.instantiate('/Discovery/ObjectWalker/object_walker')
#tenant_objects = $evm.vmdb('CloudTenant').find(:all)
#@tenant_objects.each do | tenant |
#  $evm.log(:info, "Tenant \'#{tenant.name}\' exists in OpenStack ")
#  $evm.log(:info, "Provider: #{$evm.vmdb('ems', tenant.ems_id).name}\n")
#end


#clusters = $evm.vmdb(:EmsCluster).find(:all)
#$evm.log(:info, " VISH_DEBUG: #{clusters}")

# Calculate the cost for the CPU, memory, and storage
cpu_cost = cpu_price * cpu_count
mem_cost = mem_price * mem_size
storage_cost = (storage_price * storage_size)

# Deteremine the total cost and round to two decimal points
total_cost = sprintf("%.2f", (cpu_cost + mem_cost + storage_cost).round(2))

$evm.log(:info, " cpu count: #{cpu_count}       cpu cost = #{cpu_cost}") if debug
$evm.log(:info, " memory GB: #{mem_size}     memory cost = #{mem_cost}") if debug
$evm.log(:info, "storage GB: #{storage_size}     storage = #{storage_cost}") if debug
$evm.log(:info, "total cost = #{total_cost}") if debug

# Set form field to the calculated value
$evm.object['value'] = "$#{total_cost}"
# Set the form field to be read-only so the user cannot change it
$evm.object['read_only'] = true

$evm.log(:info, "*********************** CALCULATE PRICING METHOD ENDED ***********************") if debug
  
exit MIQ_OK
