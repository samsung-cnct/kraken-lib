<#
	title           :utils.ps1
	description     :utils
	author          :Samsung SDSRA
#>

function warn 
{
  param( [string]$Message )
  write-host "WARNING: $Message" -foregroundcolor "yellow"
}

function error 
{
  param( [string]$Message )
  write-host "ERROR: $Message" -foregroundcolor "red"
}

function inf 
{
  param( [string]$Message )
  write-host "$Message" -foregroundcolor "green"
}