
function get-LenovoWarranty([Parameter(Mandatory = $true)]$SourceDevice, $client) {
    $today = Get-Date -Format yyyy-MM-dd
    $APIURL = "https://pcsupport.lenovo.com/us/en/api/v4/mse/getproducts?productId=$SourceDevice"
    $Req = Invoke-RestMethod -Uri $APIURL -Method get
    
    if($req.id){
        $APIURL = "https://pcsupport.lenovo.com/us/en/products/$($req.id)/warranty"
        $Req = Invoke-RestMethod -Uri $APIURL -Method get
        $search = $Req |Select-String -Pattern "var ds_warranties = window.ds_warranties \|\| (.*);[\r\n]*"
        $jsonWarranties = $search.matches.groups[1].value |ConvertFrom-Json
        }

    if ($jsonWarranties.BaseWarranties) {
        $warfirst = $jsonWarranties.BaseWarranties |sort-object -property [DateTime]End |select-object -first 1
        $warlatest = $jsonWarranties.BaseWarranties |sort-object -property [DateTime]End |select-object -last 1
        $WarObj = [PSCustomObject]@{
            'Serial' = $jsonWarranties.Serial
            'Warranty Product name' = $jsonWarranties.ProductName
            'StartDate' = [DateTime]($warfirst.Start)
            'EndDate' = [DateTime]($warlatest.End)
            'Warranty Status' = $warlatest.StatusV2
            'Client' = $Client
            'Product Image' = $jsonWarranties.ProductImage
            'Warranty URL' = $jsonWarranties.WarrantyUpgradeURLInfo.WarrantyURL
        }
    }
    else {
        $WarObj = [PSCustomObject]@{
            'Serial' = $SourceDevice
            'Warranty Product name' = 'Could not get warranty information'
            'StartDate' = $null
            'EndDate' = $null
            'Warranty Status' = 'Could not get warranty information'
            'Client' = $Client
            'Product Image' = ""
            'Warranty URL' = ""
        }
    }
    return $WarObj
}
