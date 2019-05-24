Function Pkcs10CertEnroll {
    [cmdletBinding()]

    param(
        $BaseURL,  
        $UserName,      
        $Password,              
        $APIKey, 
        $Flags = 0,               
        $TemplateName,                    
        $Pkcs10Certificate           
        #$MetaFieldName1,
        #$MetaFieldValue1           
        #$MetaFieldName2,
        #$MetaFieldValue2,           
        #$MetaFieldNameN,
        #$MetaFieldValueN           
    )

    $encodedCredentials = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(($UserName + ':' + $Password)))
    $encodedAPIKey = HexEncodeBase64 -HexString $APIKey

    $uri = "$BaseURL/cmsapi/CertEnroll/3/Pkcs10"

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add('authorization', "Basic $encodedCredentials")
    $headers.Add('x-css-cms-appkey', (Convert-HexStringToBase64String -hexString $ApiKey))
    $headers.Add('content-type', 'application/json')

    $body = @{
        timestamp = ((get-date).ToUniversalTime()).ToString("yyyy-MM-ddTHH:mm:ss")
        Request = @{
            Flags = $Flags
            TemplateName = $TemplateName
            Pkcs10Request = $Pkcs10Certificate
            #metadataList = @( 
                #@{
                #    MetadataFieldTypeName = $MetaFieldName1
                #    Value = $MetaFieldValue1
                #},
                #@{
                #    MetadataFieldTypeName = $MetaFieldName2
                #    Value = $MetaFieldValue2
                #},
                #@{
                #    MetadataFieldTypeName = $MetaFieldNameN
                #    Value = $MetaFieldValueN
                #}
            #)
        }
    }

    $jsonBody = ConvertTo-Json $body -Depth 4

    Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -Body $jsonBody
}

Function HexEncodeBase64
{
    param (
        [string] $HexString
    )
    $hexDigits = $hexString
    
    if ($hexDigits.Length % 2 -ne 0)
    {
        $hexDigits = "0$hexDigits"
    }

    $bytes =
    for ($i = 0; $i -lt $hexDigits.Length - 1; $i += 2)
    {
        [System.Convert]::ToByte($hexDigits.Substring($i, 2), 16)
    }

    return [System.Convert]::ToBase64String($bytes)
}



### Example Call ###
$pkcs10Certificate = @"
        {PKCS10_CERTIFICATE}
"@
Pkcs10CertEnroll -BaseURL '{BASE_URL}' -UserName '{USER_NAME}' -Password '{PASSWORD}' `
    -APIKey '{KF_API_KEY' -TemplateName '{CERTIFICATE_TEMPLATE}' -Pkcs10Certificate $pkcs10Certificate

#{BASE_URL} - Base URL of your Keyfactor implementation - i.e. "https://your.domain"
#{USER_NAME} - AD with authority to execute Keyfactor APIs, domain included - i.e. "domain\user-name"
#{PASSWORD} - The password for {USER_NAME}
#{KF_API_KEY} - The API Key set up in Keyfactor Command => System Settings => API Applications 
#{CERTIFICATE_TEMPLATE} - The certificate template name the certificate will be created for
#{PKCS10_CERTIFICATE} - The full pkcs10 certificate beginning with "-----BEGIN NEW CERTIFICATE REQUEST-----" and ending with "-----END NEW CERTIFICATE REQUEST-----"