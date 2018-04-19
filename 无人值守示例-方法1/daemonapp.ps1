# The resource URI
$clientId = "d786bd1e-041b-4ccd-aa02-3f46c62e265c"
$tenantId = "51o365.partner.onmschina.cn"
$resourceId = "https://microsoftgraph.chinacloudapi.cn"
$login = "https://login.chinacloudapi.cn"

# Create Client Credential Using App Key
$secret = "WgRskLCnvCmgdwTNEF24eJoq7HWxSF4u%2b2XdOBsNI0c%3d"

$body="client_id="+$clientId+"&client_secret="+$secret+"&grant_type=client_credentials&resource="+$resourceId
#"https://login.chinacloudapi.cn/d93cb861-a6db-4e95-9c95-69c4d22a5374/oauth2/token" 
$Response = Invoke-WebRequest -Method Post -ContentType "application/x-www-form-urlencoded" -Uri ($login+"/$tenantId/oauth2/token") -body $body
 
$Authentication = $Response.Content|ConvertFrom-Json


write-host "Get All Users Information:"
 
$Response=Invoke-WebRequest -Method GET -Uri ($ResourceID+"/v1.0/users") -Header @{ Authorization = "BEARER "+$Authentication.access_token} -ErrorAction Stop

$responseObject = ConvertFrom-Json $Response.Content

#$responseObject
$responseObject.value | ForEach-Object { $_.userPrincipalName}