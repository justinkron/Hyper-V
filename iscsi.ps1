# This script will automatically configure iSCSI targets. Adjust to match your environment.

# host iscsi NICs
# iscsi A VLAN
$nic1 = "10.31.6.131"
# iscsi B VLAN
$nic2 = "10.31.7.131"

# Pure Array iSCSI port IPs
# iscsi A VLAN
$target1 = "10.31.6.201"
$target2 = "10.31.6.202"
# iscsi B VLAN
$target3 = "10.31.7.201"
$target4 = "10.31.7.202"

# Create the iSCSI Target portals
New-IscsiTargetPortal -InitiatorPortalAddress $nic1 -TargetPortalAddress $target1 -InitiatorInstanceName "ROOT\ISCSIPRT\0000_0"
New-IscsiTargetPortal -InitiatorPortalAddress $nic2 -TargetPortalAddress $target3 -InitiatorInstanceName "ROOT\ISCSIPRT\0000_0"

# Pause for portal creation completion
Start-sleep -seconds 2
$targetnames = Get-IscsiTarget
$targetname = $targetnames[0] 

# Connect the to the targets
# iscsi A VLAN
Connect-IscsiTarget -InitiatorPortalAddress $nic1 -TargetPortalAddress $target1 -IsMultipathEnabled $true -NodeAddress $targetname.NodeAddress -IsPersistent $true
Connect-IscsiTarget -InitiatorPortalAddress $nic1 -TargetPortalAddress $target2 -IsMultipathEnabled $true -NodeAddress $targetname.NodeAddress -IsPersistent $true
# iscsi B VLAN
Connect-IscsiTarget -InitiatorPortalAddress $nic2 -TargetPortalAddress $target3 -IsMultipathEnabled $true -NodeAddress $targetname.NodeAddress -IsPersistent $true
Connect-IscsiTarget -InitiatorPortalAddress $nic2 -TargetPortalAddress $target4 -IsMultipathEnabled $true -NodeAddress $targetname.NodeAddress -IsPersistent $true
