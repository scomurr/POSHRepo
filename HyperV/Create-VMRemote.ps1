# Create-VMRemote
# Creates a hastable of VMs with specific OSs on a remote HV server
# Author: Scott Murray
# Date: 4/19/2019

<#
LEGAL DISCLAIMER
This Sample Code is provided for the purpose of illustration only and is not
intended to be used in a production environment.  THIS SAMPLE CODE AND ANY
RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  We grant You a
nonexclusive, royalty-free right to use and modify the Sample Code and to
reproduce and distribute the object code form of the Sample Code, provided
that You agree: (i) to not use Our name, logo, or trademarks to market Your
software product in which the Sample Code is embedded; (ii) to include a valid
copyright notice on Your software product in which the Sample Code is embedded;
and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and
against any claims or lawsuits, including attorneys’ fees, that arise or result
from the use or distribution of the Sample Code.

This posting is provided "AS IS" with no warranties, and confers no rights. Use
of included script samples are subject to the terms specified
at http://www.microsoft.com/info/cpyright.htm.
#>

$Drive = "F"  # Set to the local drive to which the VM gets created on the HV server
$Set = "01" # used for grouping VMs in the HV console
$VMHost = "HV01.tst.lab" # Server to which the VMs will be deployed
$Switch = "LAN" #"LAN" # HV switch to which the VMs wil be attached

# example of VMs to be created
$VMs = @{"WD01" = "10";
         "WD02" = "10";
         "WD03" = "10";
         "WS01" = "2016";
         "WS02" = "2016"
         }

# Parent disk hashtable
# Paths are relative to to the HV server and not the script source
$Parent = @{ "2012R2" = "F:\VHDx\Win2012R2Gold\Win2012R2Gold_04052017.vhdx";
             "2008R2" = "F:\VHDx\Win2008R2Gold\Win2008R2Gold_05172017.vhdx";
             "2016" = "F:\VHDx\Win2016_Gold\Win2016Gold_01252019.vhdx";
             "2003" = "NA";                                     # 2003 is no longer supported.  The VMGuest.ISO has been removed so it is difficult to get the integration services installed
             "764" = "F:\VHDx\Win764Gold\Win764Gold_05172017.vhdx";
             "10" = "F:\VHDx\Win10_Gold\Win10Gold_01252019.vhdx"   #all business versions including ENT
             }

$Generation = @{ "2012R2" = "2";
             "2008R2" = "1"
             "2016" = "2";
             "2003" = "NA";
             "764" = "1";
             "10" = "2"
             }

#$p = (pwd).path
#cd ($drive + ":")
#cd \vhdx
$VMs.Keys | % {

    $Gen = $Generation.Item($VMs.Item($_))
	$VMName = $($Drive + '_' + $_)
	$VM = New-VM -Name $VMName -MemoryStartupBytes 1024MB -SwitchName $switch -Path $($Drive + ':\VHDX\' + $_) -Verbose -Generation $Gen -ComputerName $VMHost
    $Source = $Parent.Item($VMs.Item($_))
    $Destination = $($Drive + ':\VHDX\' + $_ + '\' + $_ + '.vhdx')
    Write-Host $Source
    Write-Host $Destination
    $sb = {param($src,$dest) copy-item $src $dest;Set-ItemProperty $dest -name IsReadOnly -value $false}
    Invoke-Command -ComputerName $VMHost -ScriptBlock $sb -ArgumentList $Source,$Destination
	Add-VMHardDiskDrive $VMName -Path $($Drive + ':\VHDX\' + $_ + '\' + $_ + '.vhdx') -ComputerName $VMHost
	Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $True -MaximumBytes 2048MB -StartupBytes 1024MB -MinimumBytes 512MB -ComputerName $VMHost
	Set-VMProcessor -VMName $VMName -Count 4 -ComputerName $VMHost
    $vhd = Get-VMHardDiskDrive -vmname $VMName -ComputerName $VMHost
    if ($Gen -eq "2") { Set-VMFirmware -VMName $vmname -FirstBootDevice $vhd -ComputerName $VMHost }

    # Configure VMs to not auto start
    $VM | Set-VM -AutomaticStartAction Nothing
    $VM | Rename-VM -NewName ($Set + "_" + $VM.VMName)

    write-host -foregroundcolor yellow "Complete"

}