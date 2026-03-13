# Set SPN for Kerberos Live migration
Import-Module ActiveDirectory
Import-Module FailoverClusters

# Variables
#$ClusterName = "YOUR_CLUSTER_NAME"  # <-- Set your cluster name here

# Get all cluster nodes dynamically
#$ClusterNodes = Get-ClusterNode -Cluster $ClusterName | Select-Object -ExpandProperty Name

# run from cluster node
$clusternodes = Get-ClusterNode

# manually
#$ClusterNodes = @(
#    "node1"
#    "node2"
#    "node3"
#)

Write-Host "Found $($ClusterNodes.Count) cluster nodes: $($ClusterNodes -join ', ')"

# Build SPN lists for every node
$AllSpns = @{}
foreach ($Node in $ClusterNodes) {
    $AllSpns[$Node] = @(
        "Microsoft Virtual System Migration Service/$Node",
        "cifs/$Node"
    )
}

$delegationProperty = "msDS-AllowedToDelegateTo"

# For each node, delegate to all OTHER nodes in the cluster
foreach ($Node in $ClusterNodes) {

    # Build the delegation SPN list: all SPNs EXCEPT this node's own
    $delegateToSpns = $ClusterNodes |
        Where-Object { $_ -ne $Node } |
        ForEach-Object { $AllSpns[$_] } 

    Write-Host "`nConfiguring delegation for $Node..."
    Write-Host "  Delegating to SPNs: $($delegateToSpns -join ', ')"

    $Account = Get-ADComputer $Node

    ## Clear existing delegation SPNs to avoid stale entries, then re-add
    #$ExistingSpns = $Account | Select-Object -ExpandProperty $delegationProperty -ErrorAction SilentlyContinue
    #if ($ExistingSpns) {
    #    $Account | Set-ADObject -Clear $delegationProperty
    #}

    $Account | Set-ADObject -Add @{$delegationProperty = $delegateToSpns}
    Set-ADAccountControl $Account -TrustedToAuthForDelegation $true

    Write-Host "  Done: $Node configured successfully."
    
}

Write-Host "`nKerberos delegation configuration complete for cluster '$ClusterName'."
