# Get-CertificateTemplates.ps1
# Retrieves certificate templates used in the local machine's certificate store

# Function to get certificate template information
function Add-CertificateTemplateInfo {
    param (
            [Parameter(
                Mandatory,
                ValueFromPipeline
            )]
            [System.Security.Cryptography.X509Certificates.X509Certificate2]
        $Certificate
    )

    begin {
        $TemplateOid = '1.3.6.1.4.1.311.21.7'
    }

    process {
        # Get certificate template information from extensions
        $TemplateInfo = $Certificate.Extensions | Where-Object { $_.Oid.Value -eq $TemplateOid }

        if ($TemplateInfo) {
                # Parse template information
            $templateString = $TemplateInfo.Format($false)
            $template = if ($templateString -match '(Template|Mall)=([^,]+)') {
                $matches[2].Trim()
            }
            if ($template -match '(.+)\((\d(\.\d+)+)\)$') {
                $Name = $Matches[1]
                $OID = $Matches[2]
            } else {
                $Name = 'unknown'
                $Oid = $template
            }

            $Certificate |
                Add-Member -MemberType NoteProperty -Name TemplateName -Value $Name -PassThru |
                Add-Member -MemberType NoteProperty -Name TemplateOID -Value $OID -PassThru
        } else {
            $Certificate
        }
    }
}

# Get all certificates from the Local Machine store
Get-ChildItem -Path Cert:\LocalMachine\My |
    Add-CertificateTemplateInfo |
    Select-Object -Property Thumbprint, Subject, Issuer, NotBefore, NotAfter, TemplateName, TemplateOID
