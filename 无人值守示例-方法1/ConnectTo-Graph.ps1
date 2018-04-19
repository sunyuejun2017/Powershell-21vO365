
<#
.功能
	获取访问令牌

.描述
    使用client_credentials方法获取访问令牌调用Office 365 Graph API获取信息

.前提要求
	
    1. 注册应用
      登录https://portal.azure.cn 注册应用程序，记录应用程序ID，密钥，并分配应用程序权限
	  在应用上配置 Microsoft Graph 的权限。
	   示例配置需要的应用程序权限有：Read directory data/Send mail as any user
    2. 获取管理员同意。
    3. 获取访问令牌。
    4. 使用访问令牌调用 Microsoft Graph。  

.示例
	GraphAPIGetAccessTokenCode.ps1 -ClientId $clientId -ClientSecret $clientSecret -tenantId $tenantId
   
.注释
	版本:        1.0
	作者:        孙跃军
	创建时间:     2018-4-19  
  
.EXAMPLE
  connectTo-Graph.ps1

#>


#----------------------------------------------------------[Declarations]----------------------------------------------------------

# 获取访问令牌
Function Get-AccessTokenCode($clientId,$secret,$resourceId,$tenantId)
{
        
  $body="client_id="+$ClientId+"&client_secret="+$ClientSecret+"&grant_type=client_credentials&resource="+$resourceId
  
  $Response = Invoke-WebRequest -Method Post -ContentType "application/x-www-form-urlencoded" -Uri ("https://login.chinacloudapi.cn/$tenantId/oauth2/token") -body $body

  $Authentication = $Response.Content | ConvertFrom-Json
  
	# 保存访问令牌
    Set-Content "$PSScriptRoot\AccessTokenCode.txt" $Authentication.access_token
}

#读取配置文件
$config = Get-Content $PSScriptRoot"\config.json" -Raw | ConvertFrom-Json



#获取访问令牌
If ((Test-Path -Path $PSScriptRoot"\AccessTokenCode.txt") -ne $false) {
	$accessToken = Get-Content $PSScriptRoot"\AccessTokenCode.txt"
}
else {
    $accessToken = $null
}

# 检查访问令牌是否超过1小时重新获取新的访问令牌
If (($accessToken -eq $null) -or ((get-date) - (get-item $PSScriptRoot"\AccessTokenCode.txt").LastWriteTime).TotalHours -gt 1) 
{
	
  	$clientId = $config.AppId.ClientId
    $resourceId = $config.AppId.ResourceUrl
    $tenantId = $config.AppId.tenantid

    #对ClientSecret进行编码
    $secret = $config.AppId.clientSecret
    $secretEncoded = [System.Web.HttpUtility]::UrlEncode($secret)
	
    # 获取访问令牌，并保存
    #Get-AccessTokenCode $clientId $secretEncoded $resourceId $tenantId
    
    & $PSScriptRoot\GraphAPIGetAccessTokenCode.ps1 -ClientId $clientId -ClientSecret $secretEncoded -tenantId $tenantId  
    # 读取访问令牌信息
    $accessToken = get-content $PSScriptRoot"\AccessTokenCode.txt"
		
} 

 # 获取所有用户信息
 $Response=Invoke-WebRequest -Method GET -Uri ($resourceId+"/v1.0/users") -Header @{ Authorization = "BEARER "+$accessToken} -ErrorAction Stop
 $responseObject = ConvertFrom-Json $Response.Content
 
 #输出用户信息
 $responseObject.value | ForEach-Object { $_.userPrincipalName}

