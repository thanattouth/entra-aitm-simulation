@{
    SchemaVersion = '1.0'
    ProjectName = 'entra-aitm-defensive-showcase'
    Environment = 'test-only'

    Governance = @{
        AuthorizationRecord = '[REQUIRED]'
        SecurityApprovalRecord = '[REQUIRED]'
        NetworkApprovalRecord = '[REQUIRED]'
        ApprovalExpiry = '[REQUIRED ISO-8601]'
        KillSwitchOwner = 'Repository owner / requesting user'
        KillSwitchBackup = '[REQUIRED]'
        NoPublicIngress = $true
    }

    Host = @{
        ComputerName = '[REQUIRED]'
        VmRoot = '[REQUIRED ABSOLUTE PATH]'
        SnapshotRoot = '[REQUIRED ABSOLUTE PATH]'
        MinimumFreeSpaceGB = 260
    }

    Network = @{
        InternalSwitchName = 'entra-aitm-lab-internal'
        SwitchType = 'Internal'
        LabCidr = '10.77.0.0/24'
        GatewayAddress = '10.77.0.1'
        DnsAddress = '10.77.0.1'
        TimeSource = '[REQUIRED APPROVED SOURCE]'
        ApprovedManagementCidrs = @('[REQUIRED]')
        ProductionDenyCidrs = @('[REQUIRED]')
        ApprovedCloudFlows = @(
            # @{ Destination = 'exact approved FQDN/CIDR'; Port = 443; Protocol = 'TCP'; Owner = 'name'; Approval = 'record'; Expiry = 'ISO-8601' }
        )
    }

    Images = @{
        Linux = '[REQUIRED ABSOLUTE ISO/VHDX PATH AND CHECKSUM RECORD]'
        Windows = '[REQUIRED ABSOLUTE ISO/VHDX PATH AND CHECKSUM RECORD]'
        Gateway = '[REQUIRED ABSOLUTE ISO/VHDX PATH AND CHECKSUM RECORD]'
    }

    Vms = @(
        @{ Name = 'lab-gateway-01'; Role = 'gateway'; Os = 'Gateway'; Cpu = 2; MemoryGB = 4; DiskGB = 32; Address = '10.77.0.1'; StartDisconnected = $true },
        @{ Name = 'lab-aitm-01'; Role = 'test-engine'; Os = 'Linux'; Cpu = 2; MemoryGB = 4; DiskGB = 40; Address = '10.77.0.10'; StartDisconnected = $true },
        @{ Name = 'lab-victim-01'; Role = 'victim'; Os = 'Windows'; Cpu = 2; MemoryGB = 6; DiskGB = 64; Address = '10.77.0.20'; StartDisconnected = $true },
        @{ Name = 'lab-attacker-01'; Role = 'validation'; Os = 'Windows'; Cpu = 2; MemoryGB = 6; DiskGB = 64; Address = '10.77.0.30'; StartDisconnected = $true },
        @{ Name = 'lab-monitor-01'; Role = 'monitor'; Os = 'Linux'; Cpu = 4; MemoryGB = 8; DiskGB = 80; Address = '10.77.0.40'; StartDisconnected = $true }
    )
}
