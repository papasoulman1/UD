###Import the module if not imported already
Import-Module -Name UniversalDashboard.Community
###Stop any running dashboards so no conflict with port numbers
Get-UDDashboard | Stop-UDDashboard
$Root = "C:\inetpub\wwwroot\Fichier"
$Session:Domaine ="groupe"
$Initialization = New-UDEndpointInitialization -Variable "Root","Session:Domaine"
$Folder = Publish-UDFolder -Path C:\inetpub\wwwroot\Fichier\ -RequestPath "/Fichier"

###HomePage
$Homepage = New-UDPage -Name 'Home-Page' -Title "Dashboard $Session:Domaine" -DefaultHomePage -Icon chart_bar -Content {
$LayoutHP = '{"lg":[{"w":3,"h":15,"x":9,"y":0,"i":"grid-element-7e7da4cf-71a1-4d5f-92f6-00f8cd677d9f","moved":false,"static":false},{"w":3,"h":5,"x":6,"y":1,"i":"grid-element-CountDisaUser","moved":false,"static":false},{"w":3,"h":5,"x":0,"y":1,"i":"grid-element-CountCreateGroup","moved":false,"static":false},{"w":3,"h":5,"x":3,"y":1,"i":"grid-element-CountCreaUser","moved":false,"static":false},{"w":3,"h":5,"x":0,"y":4,"i":"grid-element-CountDisaComp","moved":false,"static":false},{"w":3,"h":5,"x":3,"y":4,"i":"grid-element-CountInaUser","moved":false,"static":false},{"w":3,"h":5,"x":6,"y":4,"i":"grid-element-CountInaComp","moved":false,"static":false},{"w":3,"h":2,"x":0,"y":8,"i":"grid-element-CountPw","moved":false,"static":false},{"w":3,"h":3,"x":6,"y":8,"i":"grid-element-CountEmptyGroup","moved":false,"static":false},{"w":3,"h":1,"x":3,"y":6,"i":"grid-element-DomaineHP","moved":false,"static":false},{"w":7,"h":1,"x":1,"y":9,"i":"grid-element-Note","moved":false,"static":false}]}'
New-UDGridLayout -Layout $LayoutHP -Content {
        
        New-UDSwitch -Id "DomaineHp" -OnText "ImATest" -OffText "groupe" -OnChange{
        Switch($EventData){
            $true{
            $Session:Domaine = "ImATest"
            }
            $false
            {
            $Session:Domaine = "groupe"
            }
            }
        }

		New-UDGrid -Id "7e7da4cf-71a1-4d5f-92f6-00f8cd677d9f" -Headers @("Name", "Size", "Download") -Properties @("Name", "Size", "Download")  -Endpoint {
                Get-ChildItem -Path C:\inetpub\wwwroot\Fichier | ForEach-Object {
                    [PSCustomObject]@{
                        Name = $_.Name
                        Size = "$([Math]::Floor($_.Length / 1KB))KB"
                        Download = New-UDLink -Text "Download" -Url "/Fichier/$($_.Name)"
                    }
                } | Out-UDGridData }
		New-UDCounter -Id "CountCreaUser" -Title "Nombre d'utilisateur créé" -AutoRefresh -Icon calculator
		New-UDCounter -Id "CountCreateGroup" -Title "Nombre de groupe créé" -AutoRefresh -Icon calculator -Links @(New-UDLink -Text 'Télécharger CSV' -Url '/Fichier/creategroup_groupe.csv'
                                                                                                                   New-UDLink -Text 'Plus de détails' -Url '/CreateGroup')
		New-UDCounter -Id "CountDisaUser" -Title "Nombre d'utilisateur désactivé " -AutoRefresh -Icon calculator
		New-UDCounter -Id "CountDisaComp" -Title "Nombre d'ordinateur désactivé " -AutoRefresh -Icon calculator
		New-UDCounter -Id "CountInaUser" -Title "Nombre d'utilisateur inactif" -AutoRefresh -Icon calculator
		New-UDCounter -Id "CountInaComp" -Title "Nombre d'ordinateur inactif " -AutoRefresh -Icon calculator
		New-UDCounter -Id "CountPw" -Title "Mot de passe qui n'expire pas" -AutoRefresh -Icon calculator
		New-UDCounter -Id "CountEmptyGroup" -Title "Nombre de groupe vide" -AutoRefresh -Icon calculator 
        
	}
}

###Page CreateUser
$CreateUser = New-UDPage -Name 'CreateUser' -Title "Utilisateur crée depuis au moins 90 jours $Domaine" -Icon user_plus -Content {
    $LayoutUser = '{"lg":[{"w":7,"h":13,"x":0,"y":0,"i":"grid-element-topLeft","moved":false,"static":false},{"w":3,"h":3,"x":7,"y":0,"i":"grid-element-CountCreaUser","moved":false,"static":false},{"w":5,"h":4,"x":7,"y":3,"i":"grid-element-grid","moved":false,"static":false},{"w":3,"h":3,"x":0,"y":0,"i":"grid-element-SelectDomaineCU","moved":false,"static":false},{"w":3,"h":3,"x":4,"y":0,"i":"grid-element-dlCreateUser","moved":false,"static":false}]}'
    New-UDGridLayout -Layout $LayoutUser -Content {
        New-UDChart -Id "topLeft" -Type Bar -Endpoint {
            $csv = import-csv $Root\createuser_$Session:Domaine.csv
            $csv | Select-Object "WhenCreated", "DistinguishedName", "Enabled","SamAccountName" | Out-UDChartData -LabelProperty "WhenCreated" -Dataset @(
                New-UDChartDataset -DataProperty "Enabled" -Label "Enabled" -BackgroundColor "#279af1"

            )
        } -Labels @("WhenCreated") -Options @{
            scales = @{
                xAxes = @(
                    @{
                        stacked = $true
                    }
                )
                yAxes = @(
                    @{
                        stacked = $true
                    }
                )
            }
        }

        New-UDCounter -Id "CountCreaUser" -Title "Nombre d'utilisateur" -AutoRefresh -Icon calculator -Endpoint {
            $csvcount = Import-Csv C:\inetpub\wwwroot\Fichier\createuser_groupe.csv
            $csvcount.count-1
        }
       
        New-UDSelect -Id "SelectDomaineCU" -Label "Selection du Domaine (defaut groupe)" -Option {
            New-UDSelectOption -Name "Groupe" -Value groupe
            New-UDSelectOption -Name "ImATest" -Value ImATest
                }

                New-UDLink -Id "dlCreateUser" -Text "Télécharger le fichier Csv" -Url "Fichier/createuser_groupe.csv"

        New-UDGrid -Id "grid" -Title "Fichier : " -Headers @("WhenCreated", "DistinguishedName", "Enabled") -Properties @("WhenCreated", "DistinguishedName", "Enabled") -DefaultSortColumn "WhenCreated" -DefaultSortDescending -Endpoint {
            $csv = import-csv $Root\createuser_groupe.csv 
            $csv | Select-Object "WhenCreated", "DistinguishedName", "Enabled" | Out-UDGridData
        } -PageSize 4
    }

    
}

###Page CreateGroup
$CreateGroup = New-UDPage -Name 'CreateGroup' -Title "Groupe crée depuis au moins 90 jours $Domaine" -Icon users -Content {

    $LayoutComp = '{"lg":[{"w":9,"h":10,"x":0,"y":1,"i":"grid-element-CreateGroup","moved":false,"static":false},{"w":3,"h":3,"x":10,"y":0,"i":"grid-element-CountCreateGroup","moved":false,"static":false},{"w":3,"h":3,"x":10,"y":0,"i":"grid-element-SelectDomaine","moved":false,"static":false},{"w":3,"h":3,"x":10,"y":8,"i":"grid-element-dlCreateGroup","moved":false,"static":false}]}'
    New-UDGridLayout -Layout $LayoutComp -Content {
        New-UDCounter -Id "CountCreateGroup" -Title "Nombre de groupe " -AutoRefresh -Icon calculator -Endpoint {
            $csvcountord = Import-Csv C:\inetpub\wwwroot\Fichier\creategroup_groupe.csv
            $csvcountord.count-1
        }

        New-UDSelect -Id "SelectDomaine" -Label "Selection du Domaine (defaut groupe)" -Option {
            New-UDSelectOption -Name "Groupe" -Value groupe
            New-UDSelectOption -Name "ImATest" -Value ImATest
                }

                New-UDLink -Id "dlCreateGroup" -Text "Télécharger le fichier Csv" -Url "Fichier/creategroup_groupe.csv"
       
        New-UDGrid -Id "CreateGroup" -Title "Fichier : " -Headers @("WhenCreated", "DistinguishedName", "GroupCategory") -Properties @("WhenCreated", "DistinguishedName", "GroupCategory") -DefaultSortColumn "WhenCreated" -DefaultSortDescending -Endpoint {
            $csv = import-csv $Root\creategroup_groupe.csv
            $csv | Select-Object "WhenCreated", "DistinguishedName", "GroupCategory" | Out-UDGridData
        } -PageSize 11
    }
}

###Page DisableUser
$DisableUser = New-UDPage -Name 'DisableUser' -Title "Utilisateur désactivé $Domaine" -Icon user_alt_slash -Content {
    $LayoutComp = '{"lg":[{"w":9,"h":10,"x":0,"y":1,"i":"grid-element-DisableUser","moved":false,"static":false},{"w":3,"h":3,"x":10,"y":0,"i":"grid-element-CountDisaUser","moved":false,"static":false},{"w":3,"h":3,"x":10,"y":0,"i":"grid-element-SelectDomaine","moved":false,"static":false},{"w":3,"h":3,"x":10,"y":8,"i":"grid-element-dlDisaUser","moved":false,"static":false}]}'
    New-UDGridLayout -Layout $LayoutComp -Content {
        New-UDCounter -Id "CountDisaUser" -Title "Nombre d'utilisateur" -AutoRefresh -Icon calculator -Endpoint {
            $csvcountDisaUser = Import-Csv C:\inetpub\wwwroot\Fichier\disableduseracc_groupe.csv
            $csvcountDisaUser.count-1
        }

        New-UDSelect -Id "SelectDomaine" -Label "Selection du Domaine (defaut groupe)" -Option {
            New-UDSelectOption -Name "Groupe" -Value groupe
            New-UDSelectOption -Name "ImATest" -Value ImATest
                }

                New-UDLink -Id "dlDisaUser" -Text "Télécharger le fichier Csv" -Url "Fichier/disableduseracc_groupe.csv"
       
        New-UDGrid -Id "DisableUser" -Title "Fichier : " -Headers @("SamAccountName", "DistinguishedName") -Properties @("SamAccountName", "DistinguishedName") -DefaultSortColumn "SamAccountName" -DefaultSortDescending -Endpoint {
            $csv = import-csv $Root\disableduseracc_groupe.csv
            $csv | Select-Object "SamAccountName", "DistinguishedName"| Out-UDGridData
        } -PageSize 11
    }
}

###Page DisableComp
$DisableComp = New-UDPage -Name 'DisableComp' -Title "Ordinateur désactivé $Domaine" -Icon laptop_code -Content {
    $LayoutComp = '{"lg":[{"w":9,"h":10,"x":0,"y":1,"i":"grid-element-DisableComp","moved":false,"static":false},{"w":3,"h":3,"x":10,"y":0,"i":"grid-element-CountDisaComp","moved":false,"static":false},{"w":3,"h":3,"x":10,"y":0,"i":"grid-element-SelectDomaine","moved":false,"static":false},{"w":3,"h":3,"x":10,"y":8,"i":"grid-element-dlDisaComp","moved":false,"static":false}]}'
    New-UDGridLayout -Layout $LayoutComp -Content {
        New-UDCounter -Id "CountDisaComp" -Title "Nombre d'ordinateur désactivé" -AutoRefresh -Icon calculator -Endpoint {
            $csvcountDisaComp = Import-Csv C:\inetpub\wwwroot\Fichier\DisabledComps_groupe.CSV
            $csvcountDisaComp.count-1
        }

        New-UDSelect -Id "SelectDomaine" -Label "Selection du Domaine (defaut groupe)" -Option {
            New-UDSelectOption -Name "Groupe" -Value groupe
            New-UDSelectOption -Name "ImATest" -Value ImATest
                }

                New-UDLink -Id "dlDisaComp" -Text "Télécharger le fichier Csv" -Url "Fichier/DisabledComps_groupe.csv"
       
        New-UDGrid -Id "DisableComp" -Title "Fichier :" -Headers @("SamAccountName", "DistinguishedName","OperatingSystem") -Properties @("SamAccountName", "DistinguishedName","OperatingSystem") -DefaultSortColumn "SamAccountName" -DefaultSortDescending -Endpoint {
            $csv = import-csv $Root\DisabledComps_groupe.CSV
            $csv | Select-Object "SamAccountName", "DistinguishedName","OperatingSystem"| Out-UDGridData
        } -PageSize 11
    }

}

###Page InactiveUser
$InactiveUser = New-UDPage -Name 'InactiveUser' -Title "Utilisateur inactif depuis au moins 90 jours $Domaine" -Icon user_clock -Content {
    $LayoutComp = '{"lg":[{"w":9,"h":10,"x":0,"y":1,"i":"grid-element-InactiveUser","moved":false,"static":false},{"w":3,"h":3,"x":10,"y":0,"i":"grid-element-CountInaUser","moved":false,"static":false},{"w":3,"h":3,"x":10,"y":0,"i":"grid-element-SelectDomaine","moved":false,"static":false},{"w":3,"h":3,"x":10,"y":8,"i":"grid-element-dlInaUser","moved":false,"static":false}]}'
    New-UDGridLayout -Layout $LayoutComp -Content {
        New-UDCounter -Id "CountInaUser" -Title "Nombre d'utilisateur " -AutoRefresh -Icon calculator -Endpoint {
            $csvcountInaUser = Import-Csv C:\inetpub\wwwroot\Fichier\inactiveuser-groupe.csv
            $csvcountInaUser.count-1
        }

        New-UDSelect -Id "SelectDomaine" -Label "Selection du Domaine (defaut groupe)" -Option {
            New-UDSelectOption -Name "Groupe" -Value groupe
            New-UDSelectOption -Name "ImATest" -Value ImATest
                }

                New-UDLink -Id "dlInaUser" -Text "Télécharger le fichier Csv" -Url "Fichier/inactiveuser-groupe.csv"
       
        New-UDGrid -Id "InactiveUser" -Title "Fichier : " -Headers @("LastLogonDate", "Distinguishedname") -Properties @("LastLogonDate", "Distinguishedname") -DefaultSortColumn "LastLogonDate" -DefaultSortDescending -Endpoint {
            $csv = import-csv $Root\inactiveuser-groupe.csv
            $csv | Select-Object "LastLogonDate", "Distinguishedname"| Out-UDGridData
        } -PageSize 11
    }
}

###Page InactiveComputer
$InactiveComp = New-UDPage -Name 'InactiveComp' -Title "Ordinateur inactif depuis au moins 90 jours $Domaine" -Icon hdd -Content {
$Layout = '{"lg":[{"w":9,"h":14,"x":0,"y":0,"i":"grid-element-2753877e-4714-4d22-aa26-eb6f09e92f4a","moved":false,"static":false},{"w":3,"h":4,"x":9,"y":0,"i":"grid-element-CountInaComp","moved":false,"static":false},{"w":3,"h":3,"x":10,"y":0,"i":"grid-element-SelectDomaine","moved":false,"static":false},{"w":3,"h":3,"x":10,"y":8,"i":"grid-element-dlInaComp","moved":false,"static":false}]}'
    New-UDGridLayout -Layout $Layout -Content {
		New-UDCounter -Id "CountInaComp" -Title "Nombre d'utilisateur " -AutoRefresh -Icon calculator -Endpoint {
            $csvcountInaComp = Import-Csv C:\inetpub\wwwroot\Fichier\inactivecomp_groupe.csv
            $csvcountInaComp.count-1
        }
        New-UDSelect -Id "SelectDomaine" -Label "Selection du Domaine (defaut groupe)" -Option {
            New-UDSelectOption -Name "Groupe" -Value groupe
            New-UDSelectOption -Name "ImATest" -Value ImATest
                }

                New-UDLink -Id "dlInaComp" -Text "Télécharger le fichier Csv" -Url "Fichier/inactivecomp_groupe.csv"

	
        New-UDGrid -Id "2753877e-4714-4d22-aa26-eb6f09e92f4a" -Title "Fichier : " -Headers @("lastlogondate", "DistinguishedName") -Properties @("lastlogondate", "DistinguishedName") -DefaultSortColumn "lastlogondate" -DefaultSortDescending -Endpoint {
            $csv = import-csv $Root\inactivecomp_groupe.csv
            $csv | Select-Object "lastlogondate", "DistinguishedName"| Out-UDGridData
        } -PageSize 11
	}
}

###Page PwNeverExpire
$PwNeverExpire = New-UDPage -Name 'PwNeverExpire' -Title "Mot de passe qui n'expire jamais $Domaine" -Icon key -Content {
    $Layout = '{"lg":[{"w":9,"h":14,"x":0,"y":0,"i":"grid-element-GridPw","moved":false,"static":false},{"w":3,"h":4,"x":9,"y":0,"i":"grid-element-CountPw","moved":false,"static":false},{"w":3,"h":3,"x":10,"y":0,"i":"grid-element-SelectDomaine","moved":false,"static":false},{"w":3,"h":3,"x":10,"y":8,"i":"grid-element-dlPw","moved":false,"static":false}]}'
    New-UDGridLayout -Layout $Layout -Content {
		New-UDCounter -Id "CountPw" -Title "Nombre de mot de passe" -AutoRefresh -Icon calculator -Endpoint {
            $csvcountInaComp = Import-Csv C:\inetpub\wwwroot\Fichier\pw_never_expires_groupe.csv
            $csvcountInaComp.count-1
        }
        New-UDSelect -Id "SelectDomaine" -Label "Selection du Domaine (defaut groupe)" -Option {
            New-UDSelectOption -Name "Groupe" -Value groupe
            New-UDSelectOption -Name "ImATest" -Value ImATest
                }

                New-UDLink -Id "dlPw" -Text "Télécharger le fichier Csv" -Url "Fichier/pw_never_expires_groupe.csv"

	
        New-UDGrid -Id "GridPw" -Title "Fichier : " -Headers @("Name", "DistinguishedName","Enabled") -Properties @("Name", "DistinguishedName","Enabled") -DefaultSortColumn "Enabled" -DefaultSortDescending -Endpoint {
            $csv = import-csv $Root\pw_never_expires_groupe.csv
            $csv | Select-Object "Name", "DistinguishedName","Enabled"| Out-UDGridData
        } -PageSize 11
	}
}

$EmptyGroup = New-UDPage -Name 'EmptyGroup' -Title "Groupe vide $Domaine" -Icon folder_open -Content {
    $Layout = '{"lg":[{"w":9,"h":14,"x":0,"y":0,"i":"grid-element-GridEmptyGroup","moved":false,"static":false},{"w":3,"h":4,"x":9,"y":0,"i":"grid-element-CountEmptyGroup","moved":false,"static":false},{"w":3,"h":3,"x":10,"y":0,"i":"grid-element-SelectDomaine","moved":false,"static":false},{"w":3,"h":3,"x":10,"y":8,"i":"grid-element-dlEmptyGroup","moved":false,"static":false}]}'
    New-UDGridLayout -Layout $Layout -Content {
		New-UDCounter -Id "CountEmptyGroup" -Title "Nombre de groupe vide" -AutoRefresh -Icon calculator -Endpoint {
            $csvcountInaComp = Import-Csv C:\inetpub\wwwroot\Fichier\ademptygroup_groupe.csv
            $csvcountInaComp.count-1
        }
        New-UDSelect -Id "SelectDomaine" -Label "Selection du Domaine (defaut groupe)" -Option {
            New-UDSelectOption -Name "Groupe" -Value groupe
            New-UDSelectOption -Name "ImATest" -Value ImATest
                }

                New-UDLink -Id "dlEmptyGroup" -Text "Télécharger le fichier Csv" -Url "Fichier/ademptygroup_groupe.csv"

	
        New-UDGrid -Id "GridEmptyGroup" -Title "Fichier : " -Headers @("Name", "DistinguishedName") -Properties @("Name", "DistinguishedName") -DefaultSortColumn "Name" -DefaultSortDescending -Endpoint {
            $csv = import-csv $Root\ademptygroup_groupe.csv
            $csv | Select-Object "Name", "DistinguishedName"| Out-UDGridData
        } -PageSize 11
	}
}

$Footer = New-UDFooter -Id "footer"
$Dashboard = New-UDDashboard -Footer $Footer -Title "AD Dashboard" -Pages @(
    $Homepage, $CreateUser,$CreateGroup,$DisableUser, $DisableComp, $InactiveUser,$InactiveComp, $PwNeverExpire, $EmptyGroup
) -EndpointInitialization $Initialization
Start-UDDashboard -Dashboard $Dashboard -Port 8090 -PublishedFolder $Folder -AutoReload
