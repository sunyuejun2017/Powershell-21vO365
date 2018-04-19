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
.LINK

#>

#-----------------------------------------------------------[Execution]------------------------------------------------------------
[CmdletBinding()]
PARAM(
	[parameter(ValueFromPipeline=$true,
				ValueFromPipelineByPropertyName=$true,
				Mandatory=$true)]
	[string]$ClientId,

	[parameter(ValueFromPipeline=$true,
				ValueFromPipelineByPropertyName=$true,
				Mandatory=$true)]
    [string]$ClientSecret,
    [parameter(ValueFromPipeline=$true,
				ValueFromPipelineByPropertyName=$true,
				Mandatory=$true)]
	[string]$tenantId
)
BEGIN
{
	$ResourceUrl = "https://microsoftgraph.chinacloudapi.cn"
}
PROCESS
{
	Function Get-AuthCode {
        

        $body="client_id="+$ClientId+"&client_secret="+$ClientSecret+"&grant_type=client_credentials&resource="+$ResourceUrl
        
        $Response = Invoke-WebRequest -Method Post -ContentType "application/x-www-form-urlencoded" -Uri ("https://login.chinacloudapi.cn/$tenantId/oauth2/token") -body $body
 
        $Authentication = $Response.Content|ConvertFrom-Json
        
        #
        $env:code = $Authentication.access_token
      }


 	
	Get-AuthCode
	$authCode = $env:code

	# 保存访问令牌
    Set-Content ".\AccessTokenCode.txt" $authCode
  
  
}