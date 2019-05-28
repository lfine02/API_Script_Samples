### Enroll a new certificate via server generated private key and provided certificate data

### DIRECTIONS:
### 1) See sample call at bottom of file
### 2) To add additional certificate DN fields, subject alternate name, and meta data, uncomment/add the necessary MetaField Name/Value pairs 
###       in the "param" section as well as in the "SubjectNameAttributes", "SubjectAltNameElements, and "metadataList" sections.

Function Pkcs12CertEnroll {
    [cmdletBinding()]

    param(
        $BaseURL,  
        $UserName,      
        $Password,              
        $APIKey, 
        $Flags = 0,               
        $TemplateName,                    
        $Pkcs12Password,
        $SN_CN
        #$SN_OU,
        #$SN_O,
        #$SN_L,
        #$SN_ST,
        #$SN_C,
        #$SA_KEY1,
        #$SA_VALUE1,
        #$SA_KEY2,
        #$SA_VALUE2,
        #$SA_KEYx,
        #$SA_VALUEx,
        #$MetaFieldName1,
        #$MetaFieldValue1           
        #$MetaFieldName2,
        #$MetaFieldValue2,           
        #$MetaFieldNameN,
        #$MetaFieldValueN           
    )

    $encodedCredentials = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(($UserName + ':' + $Password)))
    $encodedAPIKey = HexEncodeBase64 -HexString $APIKey

    $uri = "$BaseURL/cmsapi/CertEnroll/3/Pkcs12"

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add('authorization', "Basic $encodedCredentials")
    $headers.Add('x-css-cms-appkey', $encodedAPIKey)
    $headers.Add('content-type', 'application/json')

    $body = @{
        timestamp = ((get-date).ToUniversalTime()).ToString("yyyy-MM-ddTHH:mm:ss")
        Request = @{
            Flags = $Flags
            TemplateName = $TemplateName
            Pkcs12Password  = $Pkcs12Password
            SubjectNameAttributes = @{
                CN = '$SN_CN'
	            #OU = '$SN_OU'
	            #O = '$SN_O'
	            #L = '$SN_L'
	            #ST = '$SN_ST'
	            #C = '$SN_C'
            
	        #SubjectAltNameElements = @(
	            #@$key='$SA_KEY1'; value='$SA_VALUE1',
	            #@$key='$SA_KEY2'; value='$SA_VALUE2',
	            #
	            #
	            #
	            #@$KEY='$SA_KEYx'; value='$SA_VALUEx'
	        #)
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

        $BaseURL,  
        $UserName,      
        $Password,              
        $APIKey, 
        $Flags = 0,               
        $TemplateName,                    
        $Pkcs12Password,
        $SN_CN
        #$SN_OU,
        #$SN_O,
        #$SN_L,
        #$SN_ST,
        #$SN_C,
        #$SA_KEY1,
        #$SA_VALUE1,
        #$SA_KEY2,
        #$SA_VALUE2,
        #$SA_KEYx,
        #$SA_VALUEx,
        #$MetaFieldName1,
        #$MetaFieldValue1           
        #$MetaFieldName2,
        #$MetaFieldValue2,           
        #$MetaFieldNameN,
        #$MetaFieldValueN           


### Example Call ###
Pkcs12CertEnroll -BaseURL '{BASE_URL}' -UserName '{USER_NAME}' -Password '{PASSWORD}' `
    -APIKey '{KF_API_KEY}' -TemplateName '{CERTIFICATE_TEMPLATE}' -Pkcs12Password '{pkcs12Password}' `
    -SN_CN '{COMMON_NAME}'


#{BASE_URL} - Base URL of your Keyfactor implementation - i.e. "https://your.domain"
#{USER_NAME} - AD with authority to execute Keyfactor APIs, domain included - i.e. "domain\user-name"
#{PASSWORD} - The password for {USER_NAME}
#{KF_API_KEY} - The API Key set up in Keyfactor Command => System Settings => API Applications 
#{CERTIFICATE_TEMPLATE} - The certificate template name the certificate will be created for
#{PKCS10_CERTIFICATE} - The full pkcs10 certificate beginning with "-----BEGIN NEW CERTIFICATE REQUEST-----" and ending with "-----END NEW CERTIFICATE REQUEST-----"
#$SN_CN - The certificate's common name
#$SN_OU - The certificate's organizational unit
#$SN_O - The certificate's organization
#$SN_L - The certificate's location
#$SN_ST - The certificate's state
#$SN_C - The certificate's country
#$SA_KEYn/#$SA_VALUEn - Name value pairs for certificate subject alternate name
#$MetaFieldName1/#$MetaFieldValue1 - Name value pairs for Keyfactor meta data fields         

