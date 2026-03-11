# SharePoint DMS Setup Script
# Site: https://ofekpoint.sharepoint.com/sites/AITECH

# Install PnP PowerShell if needed
if (!(Get-Module -ListAvailable -Name PnP.PowerShell)) {
    Write-Host "Installing PnP.PowerShell..." -ForegroundColor Yellow
    Install-Module PnP.PowerShell -Force -AllowClobber -Scope CurrentUser
}

# Configuration
$siteUrl = "https://ofekpoint.sharepoint.com/sites/AITECH"
$libName = "DMS Documents"

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "SharePoint DMS Setup" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

# Connect to SharePoint
Write-Host "Connecting to $siteUrl..." -ForegroundColor Cyan
Connect-PnPOnline -Url $siteUrl -Interactive

# Create Document Library
Write-Host "`nCreating Document Library..." -ForegroundColor Yellow
$list = Get-PnPList -Identity $libName -ErrorAction SilentlyContinue
if (!$list) {
    New-PnPList -Title $libName -Template DocumentLibrary -EnableVersioning
    Write-Host "Document Library created" -ForegroundColor Green
}
else {
    Write-Host "Document Library already exists" -ForegroundColor Gray
}

# Enable versioning
Set-PnPList -Identity $libName -EnableVersioning $true -MajorVersions 50

# Add metadata columns
Write-Host "`nAdding metadata columns..." -ForegroundColor Yellow

# Project column
$field = Get-PnPField -List $libName -Identity "Project" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $libName -DisplayName "Project" -InternalName "Project" -Type Choice -Choices @("SpaceX Project","Tesla Project","NVIDIA Project","Project Alpha","Project Beta") -AddToDefaultView
    Write-Host "Added: Project" -ForegroundColor Green
}

# Client column
$field = Get-PnPField -List $libName -Identity "Client" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $libName -DisplayName "Client" -InternalName "Client" -Type Text -AddToDefaultView
    Write-Host "Added: Client" -ForegroundColor Green
}

# Department column
$field = Get-PnPField -List $libName -Identity "Department" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $libName -DisplayName "Department" -InternalName "Department" -Type Choice -Choices @("Engineering","Finance","HR","Legal","Operations","R&D") -AddToDefaultView
    Write-Host "Added: Department" -ForegroundColor Green
}

# Document Status column
$field = Get-PnPField -List $libName -Identity "DocumentStatus" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $libName -DisplayName "Document Status" -InternalName "DocumentStatus" -Type Choice -Choices @("Draft","In Review","Approved","Released","Archived") -AddToDefaultView
    Write-Host "Added: Document Status" -ForegroundColor Green
}

# Priority column
$field = Get-PnPField -List $libName -Identity "Priority" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $libName -DisplayName "Priority" -InternalName "Priority" -Type Choice -Choices @("High","Medium","Low") -AddToDefaultView
    Write-Host "Added: Priority" -ForegroundColor Green
}

# Version Number column
$field = Get-PnPField -List $libName -Identity "VersionNumber" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $libName -DisplayName "Version Number" -InternalName "VersionNumber" -Type Text
    Write-Host "Added: Version Number" -ForegroundColor Green
}

# Notes column
$field = Get-PnPField -List $libName -Identity "Notes" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $libName -DisplayName "Notes" -InternalName "Notes" -Type Note -AddToDefaultView
    Write-Host "Added: Notes" -ForegroundColor Green
}

# Auto Release Date column
$field = Get-PnPField -List $libName -Identity "AutoReleaseDate" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $libName -DisplayName "Auto Release Date" -InternalName "AutoReleaseDate" -Type DateTime
    Write-Host "Added: Auto Release Date" -ForegroundColor Green
}

# Is Production Version column
$field = Get-PnPField -List $libName -Identity "IsProductionVersion" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $libName -DisplayName "Is Production Version" -InternalName "IsProductionVersion" -Type Boolean
    Write-Host "Added: Is Production Version" -ForegroundColor Green
}

# Create folders
Write-Host "`nCreating folders..." -ForegroundColor Yellow
$folders = @("Projects", "Clients", "Contracts", "Finance", "HR", "Engineering", "Versions")
foreach ($folder in $folders) {
    $existingFolder = Get-PnPFolder -Url "$libName/$folder" -ErrorAction SilentlyContinue
    if (!$existingFolder) {
        Add-PnPFolder -Name $folder -Folder $libName | Out-Null
        Write-Host "Created folder: $folder" -ForegroundColor Green
    }
}

# Create custom view
Write-Host "`nCreating custom view..." -ForegroundColor Yellow
$viewExists = Get-PnPView -List $libName -Identity "Project View" -ErrorAction SilentlyContinue
if (!$viewExists) {
    $viewFields = @("DocIcon", "LinkFilename", "Project", "Client", "DocumentStatus", "Priority", "Modified", "Editor")
    Add-PnPView -List $libName -Title "Project View" -Fields $viewFields -SetAsDefault
    Write-Host "Created: Project View" -ForegroundColor Green
}

# Create Projects List
Write-Host "`nCreating Projects list..." -ForegroundColor Yellow
$projectsList = "Projects"
$list = Get-PnPList -Identity $projectsList -ErrorAction SilentlyContinue
if (!$list) {
    New-PnPList -Title $projectsList -Template GenericList
    Write-Host "Projects list created" -ForegroundColor Green
}
else {
    Write-Host "Projects list already exists" -ForegroundColor Gray
}

# Add columns to Projects list
$field = Get-PnPField -List $projectsList -Identity "ProjectCode" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $projectsList -DisplayName "Project Code" -InternalName "ProjectCode" -Type Text -AddToDefaultView
}

$field = Get-PnPField -List $projectsList -Identity "ProjectPriority" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $projectsList -DisplayName "Priority" -InternalName "ProjectPriority" -Type Choice -Choices @("High","Medium","Low") -AddToDefaultView
}

$field = Get-PnPField -List $projectsList -Identity "ProjectStatus" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $projectsList -DisplayName "Status" -InternalName "ProjectStatus" -Type Choice -Choices @("Active","On Hold","Completed","Cancelled") -AddToDefaultView
}

# Add sample projects
Write-Host "`nAdding sample projects..." -ForegroundColor Yellow
$p1 = @{Title="SpaceX Project"; ProjectCode="SPX-001"; ProjectPriority="High"; ProjectStatus="Active"}
$p2 = @{Title="Tesla Project"; ProjectCode="TSL-002"; ProjectPriority="Medium"; ProjectStatus="Active"}
$p3 = @{Title="NVIDIA Project"; ProjectCode="NVD-003"; ProjectPriority="High"; ProjectStatus="Active"}

foreach ($proj in @($p1, $p2, $p3)) {
    $title = $proj.Title
    $filter = "Title eq '$title'"
    $existing = Get-PnPListItem -List $projectsList -Query "<View><Query><Where><Eq><FieldRef Name='Title'/><Value Type='Text'>$title</Value></Eq></Where></Query></View>" -ErrorAction SilentlyContinue
    if (!$existing) {
        Add-PnPListItem -List $projectsList -Values $proj | Out-Null
        Write-Host "Added project: $title" -ForegroundColor Green
    }
}

# Create Signature Workflows List
Write-Host "`nCreating Signature Workflows list..." -ForegroundColor Yellow
$workflowsList = "Signature Workflows"
$list = Get-PnPList -Identity $workflowsList -ErrorAction SilentlyContinue
if (!$list) {
    New-PnPList -Title $workflowsList -Template GenericList
    Write-Host "Signature Workflows list created" -ForegroundColor Green
}
else {
    Write-Host "Signature Workflows list already exists" -ForegroundColor Gray
}

# Add columns to Workflows list
$field = Get-PnPField -List $workflowsList -Identity "WorkflowStatus" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $workflowsList -DisplayName "Status" -InternalName "WorkflowStatus" -Type Choice -Choices @("Pending","In Progress","Completed","Rejected") -AddToDefaultView
}

$field = Get-PnPField -List $workflowsList -Identity "WorkflowPriority" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $workflowsList -DisplayName "Priority" -InternalName "WorkflowPriority" -Type Choice -Choices @("High","Medium","Low") -AddToDefaultView
}

$field = Get-PnPField -List $workflowsList -Identity "DueDate" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $workflowsList -DisplayName "Due Date" -InternalName "DueDate" -Type DateTime -AddToDefaultView
}

$field = Get-PnPField -List $workflowsList -Identity "CurrentApprover" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $workflowsList -DisplayName "Current Approver" -InternalName "CurrentApprover" -Type User -AddToDefaultView
}

# Final Summary
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

Write-Host "`nCreated:" -ForegroundColor Cyan
Write-Host "  - DMS Documents (Document Library)" -ForegroundColor White
Write-Host "  - Projects List" -ForegroundColor White
Write-Host "  - Signature Workflows List" -ForegroundColor White
Write-Host "  - 7 Folders" -ForegroundColor White
Write-Host "  - 9 Metadata Columns" -ForegroundColor White
Write-Host "  - 3 Sample Projects" -ForegroundColor White

Write-Host "`nSite URL: $siteUrl" -ForegroundColor Yellow
Write-Host "`nYou can now upload documents and start using the DMS!" -ForegroundColor Green

# Disconnect
Disconnect-PnPOnline
