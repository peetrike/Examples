Add-Type -TypeDefinition @'
    using System;
    using System.Runtime.InteropServices;
    public static class NativeMethods {
        [DllImport("user32.dll")]
        public static extern bool LockWorkStation();
    }
'@

[NativeMethods]::LockWorkStation()
