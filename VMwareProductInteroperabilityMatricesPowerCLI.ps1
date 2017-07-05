#Please run all the commands below, in this order, before running any of the functions.

$DataURL = Invoke-WebRequest -URI 'https://www.vmware.com/resources/compatibility/sim/data.php'
#Everything start from the "data.php" this is the "database" for the three "VMware Product Interoperability Matrices"
#https://www.vmware.com/resources/compatibility/sim/interop_matrix.php
#Interoperability
#Solution/Database Interoperability
#Upgrade Path


$CompatibilityData = $DataURL.content
#Extract with PowerShell the content from the website.


#First challenge, it is not possible to use the data as is.
#It seems to be multidimensional array created in JavaScript or PHP

#Step 1: Convert all of them in PowerShell multidimensional array


$products_for_solution_interop_JavaScriptCode = [regex]::match($CompatibilityData,'var products_for_solution_interop.*?;').value
$products_for_solution_interop_PowerShellCode = '$' + $products_for_solution_interop_JavaScriptCode.replace('var ','').replace(':[',',@(').replace(':{',',@(').replace('{','(').replace('],',')),(').replace(']},','))),(').replace(']}};',')))').replace('null','"null"').replace('true','"true"').replace(']};','))').replace('false','"false"')
Invoke-Expression $products_for_solution_interop_PowerShellCode
$products_for_solution_interop
#Original list of product/Solution


$product_versions_for_solution_interop_JavaScriptCode = [regex]::match($CompatibilityData,'var product_versions_for_solution_interop.*?;').value
$product_versions_for_solution_interop_PowerShellCode = '$' +$product_versions_for_solution_interop_JavaScriptCode.replace('var ','').replace(':[',',@(').replace(':{',',@(').replace('{','(').replace('],',')),(').replace(']},','))),(').replace(']}};',')))').replace('null','"null"').replace('true','"true"').replace(']};','))').replace('false','"false"')

Invoke-Expression $product_versions_for_solution_interop_PowerShellCode
$product_versions_for_solution_interop
#Original list of all product version.

$solutions_interop_compatible_matrix_JaveScriptCode = [regex]::match($CompatibilityData,'var solutions_interop_compatible_matrix.*?;').value
$solutions_interop_compatible_matrix_PowerShellCode = '$' + ($solutions_interop_compatible_matrix_JaveScriptCode.replace('var ','') -replace ('(:".*?")',("Impossibletoduplicate" +'$1' + "]"))).replace('Impossibletoduplicate:"',':["').replace(':null',':[null]').replace(':[',',@(').replace(':{',',@(').replace('{','(').replace('],',')),(').replace(']},','))),(').replace(']}};',')))').replace('null','"null"').replace('true','"true"').replace(']};','))').replace('false','"false"').replace(']}} || [];',')))')

Invoke-Expression $solutions_interop_compatible_matrix_PowerShellCode
#Compatibility between solution


$solutions_interop_incompatible_matrix_JaveScriptCode = [regex]::match($CompatibilityData,'var solutions_interop_incompatible_matrix.*?;').value
$solutions_interop_incompatible_matrix_PowerShellCode = '$' + ($solutions_interop_incompatible_matrix_JaveScriptCode.replace('var ','') -replace ('(:".*?")',("Impossibletoduplicate" +'$1' + "]"))).replace('Impossibletoduplicate:"',':["').replace(':null',':[null]').replace(':[',',@(').replace(':{',',@(').replace('{','(').replace('],',')),(').replace(']},','))),(').replace(']}};',')))').replace('null','"null"').replace('true','"true"').replace(']};','))').replace('false','"false"').replace(']}} || [];',')))')
Invoke-Expression $solutions_interop_incompatible_matrix_PowerShellCode
#$solutions_interop_incompatible_matrix 



#Step 2, it will be necessary to convert them to standard "Array" and work with each of them.


###First we work with the table of all product/solution
$IntermediateStep = $products_for_solution_interop | foreach{
$SolutionIndex = $_[0]
$SolutionName = $_[1][0]
$Unknown = $_[1][1]
$NewSolutionIndex  = $_[1][2]
$OldSolutionIndex  = $_[1][3]
                $Report = New-Object -Type PSObject -Prop ([ordered]@{
                'SolutionIndex' = $SolutionIndex
				'SolutionName' = $SolutionName
				'Unknown' = $Unknown
				'NewSolutionIndex' = $NewSolutionIndex
				'OldSolutionIndex' = $OldSolutionIndex
                 })    
                 Return $report            
              
}

$products_for_solution_interop_SimpleArray = $IntermediateStep | foreach{
$NewSolutionIndex = $_.NewSolutionIndex
$OldSolutionIndex = $_.OldSolutionIndex
$NewSolutionName = ($IntermediateStep | where {$_.SolutionIndex -eq $NewSolutionIndex}).SolutionName
$OldSolutionName = ($IntermediateStep| where {$_.SolutionIndex -eq $OldSolutionIndex}).SolutionName

                $Report = New-Object -Type PSObject -Prop ([ordered]@{
                'SolutionIndex' = $_.SolutionIndex
				'SolutionName' = $_.SolutionName
				'Unknown' = $_.Unknown
				'NewSolutionIndex' = $_.NewSolutionIndex
				'NewSolutionName' = $NewSolutionName
				'OldSolutionIndex' = $_.OldSolutionIndex
				'OldSolutionName' = $OldSolutionName
                 })    
                 Return $report        


}

#Use the command below to see the list of all product with their old and new version if any.
#$products_for_solution_interop_SimpleArray | ogv


#In the step below we want to identify every solution that had a different name in the past...and different solution index
$ProductWithAllSolutionIndex = $products_for_solution_interop_SimpleArray | where {$_.NewSolutionIndex -eq "null" -and $_.OldSolutionindex -ne "null" } | foreach-object{
$SolutionIndex = $_.SolutionIndex
$SolutionName = $_.SolutionName
$SolutionIndexTable = @()
$SolutionIndexTable += $SolutionIndex 
$OldSolutionIndex1 = ($products_for_solution_interop_SimpleArray | where {$_.SolutionIndex -eq $SolutionIndex}).OldSolutionIndex
$SolutionIndexTable +=  "$OldSolutionIndex1"

$OldSolutionIndex2 = ($products_for_solution_interop_SimpleArray | where {$_.SolutionIndex -eq $OldSolutionIndex1}).OldSolutionIndex
if($OldSolutionIndex2 -eq "null"){
}
Else{
	$SolutionIndexTable +=  "$OldSolutionIndex2"
	$OldSolutionIndex3 = ($products_for_solution_interop_SimpleArray | where {$_.SolutionIndex -eq $OldSolutionIndex2}).OldSolutionIndex
		if($OldSolutionIndex3 -eq "null"){
		}
		Else{	
	
		$SolutionIndexTable +=  "$OldSolutionIndex3"
		$OldSolutionIndex4 = ($products_for_solution_interop_SimpleArray | where {$_.SolutionIndex -eq $OldSolutionIndex3}).OldSolutionIndex
		
			if($OldSolutionIndex4 -eq "null"){
			}
			Else{			
					
			$SolutionIndexTable +=  "$OldSolutionIndex4"
			
			}
		}	
}

					 $Obj = New-Object -Type PSObject -Prop ([ordered]@{
					'SolutionName' = $SolutionName
					'SolutionIndexTable' = $SolutionIndexTable
					 })
					 return $Obj



}

#$ProductWithAllSolutionIndex | ogv



###Second we work with the table of all "Version" of each "product".

$product_versions_for_solution_interop_SimpleArray = @()
$product_versions_for_solution_interop| foreach{
$SolutionIndex = $_[0]
$Length = $_.length
	For ($i=1; $i -lt $Length ; $i++) {
					
					$VersionIndex = $_[$i][0]
					$VersionName = $_[$i][1][0]
					$SupportedRelease = $_[$i][1][1]
					$SolutionName = ($products_for_solution_interop_SimpleArray | where {$_.SolutionIndex -eq $SolutionIndex}).SolutionName
					 $Obj = New-Object -Type PSObject -Prop ([ordered]@{
					'SolutionIndex' = $SolutionIndex
					'SolutionName' = $SolutionName
					'VersionIndex' = $VersionIndex
					'VersionName' = $VersionName
					'SupportedRelease' = $SupportedRelease
					'SolutionAndVersion' = ($SolutionName + " - " + $VersionName)
					 })
					 $product_versions_for_solution_interop_SimpleArray += $obj
					

	}

}
$product_versions_for_solution_interop_SimpleArray
$product_versions_for_solution_interop_SimpleArray | Select SolutionAndVersion


#Hash is necessary for a later step to increase the speed.
$Version_To_Solution_Hash = @{}
	$product_versions_for_solution_interop_SimpleArray | foreach{
	$Version_To_Solution_Hash.Add($_.VersionIndex,$_.SolutionIndex)
	}
}	
#$Version_To_Solution_Hash | ogv


#Hash is necessary for a later step to increase the speed.
$SolutionAndVersion_To_VersionIndex_Hash = @{}
$product_versions_for_solution_interop_SimpleArray | foreach{
$SolutionAndVersion_To_VersionIndex_Hash.Add($_.SolutionAndVersion,$_.VersionIndex)
}
#$SolutionAndVersion_To_VersionIndex_Hash | ogv



###Third we work with the table of all product version compatible with each other.

$solutions_interop_compatible_matrix_SimpleArray = @()
$solutions_interop_compatible_matrix| foreach{
$VersionIndex1 = $_[0]
$Length = $_.length
	For ($i=1; $i -lt $Length ; $i++) {
					
					$VersionIndex2 = $_[$i][0]
					$CompatibilityDetails = $_[$i][1][0]
					 $Obj = New-Object -Type PSObject -Prop ([ordered]@{
					'VersionIndex1' = $VersionIndex1
					'VersionIndex2' = $VersionIndex2
					'CompatibilityDetails' = $CompatibilityDetails
					 })
					 $solutions_interop_compatible_matrix_SimpleArray += $obj
					

	}

}
#$solutions_interop_compatible_matrix_SimpleArray | ogv

#Compatibility null means that the solution are compatible
#Anything else, the solution are compatible and this is a comment


###Fourth we work with the table of all product version incompatible with each other.
$solutions_interop_incompatible_matrix_SimpleArray = @()
$solutions_interop_incompatible_matrix| foreach{
$VersionIndex1 = $_[0]
$Length = $_.length
	For ($i=1; $i -lt $Length ; $i++) {
					
					$VersionIndex2 = $_[$i][0]
					$CompatibilityDetails = $_[$i][1][0]
					 $Obj = New-Object -Type PSObject -Prop ([ordered]@{
					'VersionIndex1' = $VersionIndex1
					'VersionIndex2' = $VersionIndex2
					'CompatibilityDetails' = $CompatibilityDetails
					 })
					 $solutions_interop_incompatible_matrix_SimpleArray += $obj
					

	}

}
#$solutions_interop_incompatible_matrix_SimpleArray | ogv


####As you can see there is no table for "Not supported"
#The table below is used to identify all "Solution" compatible with each other. i.e. At least one match betwen versions.
#It will be used later to distinguish when two versions of two separates products are "not supported" or if the two products are just "never compatible". i.e. Never dependant of each other.
$products_interop_compatible_matrix = $solutions_interop_compatible_matrix_SimpleArray | foreach-object{
$VersionIndex1 = $_.VersionIndex1
$VersionIndex2 = $_.VersionIndex2
$SolutionIndex1 = $Version_To_Solution_Hash.Get_Item("$VersionIndex1")
$SolutionIndex2 = $Version_To_Solution_Hash.Get_Item("$VersionIndex2")
					 $Obj = New-Object -Type PSObject -Prop ([ordered]@{
				#'VersionIndex1' =  $VersionIndex1
				#'VersionIndex2' =  $VersionIndex2				
					'SolutionIndex1' = $SolutionIndex1
					'SolutionIndex2' = $SolutionIndex2
					 })
					 Return $Obj


} | select -unique SolutionIndex1,SolutionIndex2

#$products_interop_compatible_matrix | ogv



function get-InteroperabilityMatrixVersion{
<#
.SYNOPSIS
Get details about the Interoperability Matrix Version

.DESCRIPTION
You need to run many commands before running this function.
Details in the blog.
All data used in the Interoperability Matrix are stored in the file "data.php" as a kind of "database" created by script.
This funtion extact a part of the name of this file which is the "version".
If you are wonderings if the Interopability Matrix has been updated just check this value with the previous you have extracted.

.NOTES
Author: Christophe Calvet
Blog: http://www.thecrazyconsultant.com/vmware-product-interoperability-matrices-powercli

.EXAMPLE

get-InteroperabilityMatrixVersion | ogv
#>
	process{
	$InteropMatrixURL = Invoke-WebRequest -URI 'https://www.vmware.com/resources/compatibility/sim/interop_matrix.php'
	$DataPHPScript = ($InteropMatrixURL.Scripts | where-object {$_.src -like "data.php*"}).src
	$DataPHPScript.replace('data.php?v=','')
	}

} 




function get-SolutionAndVersion{
<#
.SYNOPSIS
Extract all VMware Solution and Version

.DESCRIPTION
You need to run many commands before running this function.
Details in the blog.
These commands will extract information from the VMware website "https://www.vmware.com/resources/compatibility/sim/interop_matrix.php"
These information will then be converted to a format usable by PowerShell.
This function will provide you a list of all VMware Solution and Version that you can then use in "get-SolutionVersionInterCompatibility"

.NOTES
Author: Christophe Calvet
Blog: http://www.thecrazyconsultant.com/vmware-product-interoperability-matrices-powercli

.PARAMETER IncludeReleaseNotSupported
Some releases are not supported.
By design there is no point to show them.
However you can use this switch to list them.
Not recommended.

.EXAMPLE

get-SolutionAndVersion | ogv
get-SolutionAndVersion -IncludeReleaseNotSupported | ogv

#>

	[CmdletBinding()]
	param(
	[switch]$IncludeReleaseNotSupported
	)
	process{
		if($IncludeReleaseNotSupported){
		$product_versions_for_solution_interop_SimpleArray | Select SolutionAndVersion | Sort SolutionAndVersion 
		}
		Else{
		$product_versions_for_solution_interop_SimpleArray | where {$_.SupportedRelease -eq "true"} | Select SolutionAndVersion | Sort SolutionAndVersion 
		}
	}
}



function get-SolutionVersionInterCompatibility{
<#
.SYNOPSIS
Identify compatibility between VMware solution and version.

.DESCRIPTION
You need to run many commands before running this function.
Details in the blog.
These commands will extract information from the VMware website "https://www.vmware.com/resources/compatibility/sim/interop_matrix.php"
These information will then be converted to a format usable by PowerShell.
This function is the final step and check compatibility betwen multiples products and version in one operation.
By design all products will be compared with all others, it means that every combination of products will be present twice.

.NOTES
Author: Christophe Calvet
Blog: http://www.thecrazyconsultant.com/vmware-product-interoperability-matrices-powercli

.PARAMETER SolutionAndVersionTable
Array of all VMware solution and version to be checked against each other.

.PARAMETER IncludeSolutionNeverCompatible
In some cases two solutions are never compatibile.
There is not any single "compatible" match between their versions.
By default they will be removed from the final report.
If you use this switch you can display them.

.EXAMPLE

$SolutionAndVersionTable = @()
$SolutionAndVersionTable += "VMware vCenter Server - 6.5.0"
$SolutionAndVersionTable += "VMware NSX for vSphere - 6.2.7"
$SolutionAndVersionTable += "VMware vSphere Hypervisor (ESXi) - 6.0 U3"
get-SolutionVersionInterCompatibility -SolutionAndVersionTable $SolutionAndVersionTable | ogv

get-SolutionVersionInterCompatibility -SolutionAndVersionTable $SolutionAndVersionTable -IncludeSolutionNeverCompatible| ogv


#>


	[CmdletBinding()]
	param(
	[Parameter(Mandatory=$true)]
	[string[]]$SolutionAndVersionTable,
	[switch]$IncludeSolutionNeverCompatible
	)
	process{
		$SolutionAndVersionTable | foreach-object{
		
		$SolutionAndVersion1 =  $_
		$VersionIndex1 = $SolutionAndVersion_To_VersionIndex_Hash.Get_Item($SolutionAndVersion1)
		$SolutionIndex1 = $Version_To_Solution_Hash.Get_Item($VersionIndex1)
		
			$SolutionAndVersionTable | where {$_ -ne $SolutionAndVersion1} | foreach-object{
				$SolutionAndVersion2 =  $_
				$VersionIndex2 = $SolutionAndVersion_To_VersionIndex_Hash.Get_Item($SolutionAndVersion2)
				$SolutionIndex2 = $Version_To_Solution_Hash.Get_Item($VersionIndex2)
				
				#Check if the two solutions could ever be compatible.
				#Take into account that some Solution could have new and old solution name.
				$SolutionIndexTable1 = $()
					if($ProductWithAllSolutionIndex.SolutionIndexTable -contains $SolutionIndex1){
						$ProductWithAllSolutionIndex | foreach-object{
							if($_.SolutionIndexTable -contains $SolutionIndex1){
							$SolutionIndexTable1 = $_.SolutionIndexTable
							}
						}
					}
					Else{
					$SolutionIndexTable1 += $SolutionIndex1
					}
				
				$SolutionIndexTable2 = $()
					if($ProductWithAllSolutionIndex.SolutionIndexTable -contains $SolutionIndex2){
						$ProductWithAllSolutionIndex | foreach-object{
							if($_.SolutionIndexTable -contains $SolutionIndex2){
							$SolutionIndexTable2 = $_.SolutionIndexTable
							}
						}
					}
					Else{
					$SolutionIndexTable2 += $SolutionIndex2
					}
				
				$Compatibility = "Solution Never Compatible"
				$CompatibilityDetails = "null"
				#"Solution Never Compatible" means that the two solutions don't have any compatibility.
				#It helps to identify if two specifics versions of a product are not compatible, or if the two products do not have any single "Compatibility" match in the compatiblity matrix
				
				
				$SolutionIndexTable1 | foreach-object{
				$SolutionIndex1 = $_
					$SolutionIndexTable2 | foreach-object{
					$SolutionIndex2 = $_
					
						If($products_interop_compatible_matrix |where{($_.SolutionIndex1 -eq $SolutionIndex1 -or $_.SolutionIndex1 -eq $SolutionIndex2) -and ($_.SolutionIndex2 -eq $SolutionIndex1 -or $_.SolutionIndex2 -eq $SolutionIndex2) }){
						$Compatibility = "Solution Compatible"
						}
					
					}
				
				}
				#If the two solutions have any version matches, then the solution are compatible and we can analyse if there is a match between version
		
										
				
				If($Compatibility -eq "Solution Compatible"){
				$CompatibilityMatch =  $solutions_interop_compatible_matrix_SimpleArray | where {($_.VersionIndex1 -eq $VersionIndex1 -or $_.VersionIndex1 -eq $VersionIndex2) -and ($_.VersionIndex2 -eq $VersionIndex1 -or $_.VersionIndex2 -eq $VersionIndex2)}
					if($CompatibilityMatch){
					$Compatibility  = "Compatible"
					$CompatibilityDetails = $CompatibilityMatch.CompatibilityDetails
					}
					Else{
					$Compatibility  = "Not supported"
					$CompatibilityDetails = "null"
					
						$IncompatibilityMatch =  $solutions_interop_incompatible_matrix_SimpleArray | where {($_.VersionIndex1 -eq $VersionIndex1 -or $_.VersionIndex1 -eq $VersionIndex2) -and ($_.VersionIndex2 -eq $VersionIndex1 -or $_.VersionIndex2 -eq $VersionIndex2)}
							if($IncompatibilityMatch){
							$Compatibility  = "Incompatible"
							$CompatibilityDetails = $IncompatibilityMatch.CompatibilityDetails
							}
						
										
					
					}
				
				
				}
				#If the solution are compatible
				#First if there is a "Compatible" match between version. If there is the value will be "Compatible"...same as in the VMware Interoperability Matrix
				#The "compatibility comment" will also be extracted
				#Second, if the two version are not compatible they are probably "Not supported"...same as in the VMware Interoperability Matrix
				#Third, however the solution could also not only be "Not supported" but be "Incompatible"...same as in the VMware Interoperability Matrix
			
	
				#Finally create the report and take into account the switch "IncludeSolutionNeverCompatible"
				#The information commented are not needed for a user but useful for troubleshooting and understanding how the script works in the background.
	
				if ($Compatibility -eq "Solution Never Compatible"){
				
					if($IncludeSolutionNeverCompatible){
							$Obj = New-Object -Type PSObject -Prop ([ordered]@{
							'SolutionAndVersion1' = $SolutionAndVersion1	
							'SolutionAndVersion2' = $SolutionAndVersion2
							#'VersionIndex1' = $VersionIndex1
							#'VersionIndex2' = $VersionIndex2
							#'SolutionIndex1' = $SolutionIndex1
							#'SolutionIndex2' = $SolutionIndex2
							#'SolutionIndexTable1' = $SolutionIndexTable1
							#'SolutionIndexTable2' = $SolutionIndexTable2
							'Compatibility' = $Compatibility
							'CompatibilityDetails' = $CompatibilityDetails
							 })
							 Return $Obj					
					}
				
				}
				Else{

				
				
				
							$Obj = New-Object -Type PSObject -Prop ([ordered]@{
							'SolutionAndVersion1' = $SolutionAndVersion1	
							'SolutionAndVersion2' = $SolutionAndVersion2
							#'VersionIndex1' = $VersionIndex1
							#'VersionIndex2' = $VersionIndex2
							#'SolutionIndex1' = $SolutionIndex1
							#'SolutionIndex2' = $SolutionIndex2
							#'SolutionIndexTable1' = $SolutionIndexTable1
							#'SolutionIndexTable2' = $SolutionIndexTable2
							'Compatibility' = $Compatibility
							'CompatibilityDetails' = $CompatibilityDetails
							 })
							 Return $Obj
				}			 
			
			
			}
		
		}
	}
}

