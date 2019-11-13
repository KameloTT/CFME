File preprovision_from_bundle 
   Goal - apply  vm_name as limit in Bundle. 
   Method file copy to  - /customdomain/Croc/AutomationManagement/AnsibleTower/Service/Provisioning/StateMachines/Provision/preprovision_from_bundle 
   Copy Instance  from /ManageIQ/AutomationManagement/AnsibleTower/Service/Provisioning/StateMachines/Provision/CatalogItemInitialization
   Change in pre2 Method::preprovision to Method:preprovision_from_bundle 

File cloud_subnet
   Goal - receive list of subnet in dynamic dialog field base on cloud_network choice.
   Prerequisites: dialog with name "cloud_network"(receive value from expressions) and autorefresh field "cloud_subnet" dialog
		  dialog with name "cloud_subnet" to obtain value from the method
   Method file with one schema element "execute" = cloud_subnet
   
