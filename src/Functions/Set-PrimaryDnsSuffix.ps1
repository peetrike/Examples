function Set-PrimaryDnsSuffix {
    <#
        .LINK
            https://learn.microsoft.com/windows/win32/sysinfo/computer-names
    #>
    [OutputType([bool])]
    param ([string] $Suffix)

    # https://learn.microsoft.com/windows/win32/api/sysinfoapi/ne-sysinfoapi-computer_name_format
    $ComputerNamePhysicalDnsDomain = 6

    Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;

    namespace ComputerSystem {
        public class Identification {
            [DllImport("kernel32.dll", CharSet = CharSet.Auto)]
            static extern bool SetComputerNameEx(int NameType, string lpBuffer);

            public static bool SetPrimaryDnsSuffix(string suffix) {
                try {
                    return SetComputerNameEx($ComputerNamePhysicalDnsDomain, suffix);
                }
                catch (Exception) {
                    return false;
                }
            }
        }
    }
"@
    [ComputerSystem.Identification]::SetPrimaryDnsSuffix($Suffix)
}
