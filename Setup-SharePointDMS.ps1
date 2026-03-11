# ============================================
# SharePoint DMS Setup Script
# Site: https://ofekpoint.sharepoint.com/sites/AITECH
# ============================================

# Install PnP PowerShell if not installed
if (!(Get-Module -ListAvailable -Name PnP.PowerShell)) {
    Write-Host "Installing PnP.PowerShell module..." -ForegroundColor Yellow
    Install-Module PnP.PowerShell -Force -AllowClobber -Scope CurrentUser
}

# Connect to SharePoint
$siteUrl = "https://ofekpoint.sharepoint.com/sites/AITECH"
Write-Host "Connecting to $siteUrl..." -ForegroundColor Cyan
Connect-PnPOnline -Url $siteUrl -Interactive

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Starting DMS Configuration..." -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

# ============================================
# 1. Create Document Library "DMS Documents"
# ============================================
Write-Host "Creating Document Library..." -ForegroundColor Yellow
$listName = "DMS Documents"
$list = Get-PnPList -Identity $listName -ErrorAction SilentlyContinue

if (!$list) {
    New-PnPList -Title $listName -Template DocumentLibrary -EnableVersioning -EnableMinorVersions:$false
    Write-Host "✓ Document Library '$listName' created" -ForegroundColor Green
} else {
    Write-Host "✓ Document Library '$listName' already exists" -ForegroundColor Gray
}

# Enable versioning
Set-PnPList -Identity $listName -EnableVersioning $true -MajorVersions 50

# Add custom columns to Document Library
Write-Host "`nAdding metadata columns to Document Library..." -ForegroundColor Yellow

# Project column
$field = Get-PnPField -List $listName -Identity "Project" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $listName -DisplayName "Project" -InternalName "Project" -Type Choice `
        -Choices "SpaceX Project","Tesla Project","NVIDIA Project","Project Alpha","Project Beta" `
        -AddToDefaultView
    Write-Host "✓ Added 'Project' column" -ForegroundColor Green
}

# Client column
$field = Get-PnPField -List $listName -Identity "Client" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $listName -DisplayName "Client" -InternalName "Client" -Type Text -AddToDefaultView
    Write-Host "✓ Added 'Client' column" -ForegroundColor Green
}

# Department column
$field = Get-PnPField -List $listName -Identity "Department" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $listName -DisplayName "Department" -InternalName "Department" -Type Choice `
        -Choices "Engineering","Finance","HR","Legal","Operations","R&D" `
        -AddToDefaultView
    Write-Host "✓ Added 'Department' column" -ForegroundColor Green
}

# Document Status column
$field = Get-PnPField -List $listName -Identity "DocumentStatus" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $listName -DisplayName "Document Status" -InternalName "DocumentStatus" -Type Choice `
        -Choices "Draft","In Review","Approved","Released","Archived" `
        -AddToDefaultView
    Write-Host "✓ Added 'Document Status' column" -ForegroundColor Green
}

# Priority column
$field = Get-PnPField -List $listName -Identity "Priority" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $listName -DisplayName "Priority" -InternalName "Priority" -Type Choice `
        -Choices "High","Medium","Low" `
        -AddToDefaultView
    Write-Host "✓ Added 'Priority' column" -ForegroundColor Green
}

# Version Number column
$field = Get-PnPField -List $listName -Identity "VersionNumber" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $listName -DisplayName "Version Number" -InternalName "VersionNumber" -Type Text
    Write-Host "✓ Added 'Version Number' column" -ForegroundColor Green
}

# Notes column
$field = Get-PnPField -List $listName -Identity "Notes" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $listName -DisplayName "Notes" -InternalName "Notes" -Type Note -AddToDefaultView
    Write-Host "✓ Added 'Notes' column" -ForegroundColor Green
}

# Auto Release Date column
$field = Get-PnPField -List $listName -Identity "AutoReleaseDate" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $listName -DisplayName "Auto Release Date" -InternalName "AutoReleaseDate" -Type DateTime
    Write-Host "✓ Added 'Auto Release Date' column" -ForegroundColor Green
}

# Is Production Version column
$field = Get-PnPField -List $listName -Identity "IsProductionVersion" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $listName -DisplayName "Is Production Version" -InternalName "IsProductionVersion" -Type Boolean
    Write-Host "✓ Added 'Is Production Version' column" -ForegroundColor Green
}

# Create folders in Document Library
Write-Host "`nCreating folder structure..." -ForegroundColor Yellow
$folders = @("Projects", "Clients", "Contracts", "Finance", "HR", "Engineering", "Versions")
foreach ($folder in $folders) {
    $existingFolder = Get-PnPFolder -Url "$listName/$folder" -ErrorAction SilentlyContinue
    if (!$existingFolder) {
        Add-PnPFolder -Name $folder -Folder $listName | Out-Null
        Write-Host "✓ Created folder: $folder" -ForegroundColor Green
    }
}

# Create custom views
Write-Host "`nCreating custom views..." -ForegroundColor Yellow

# Project View
$viewExists = Get-PnPView -List $listName -Identity "Project View" -ErrorAction SilentlyContinue
if (!$viewExists) {
    $fields = @("DocIcon", "LinkFilename", "Project", "Client", "DocumentStatus", "Priority", "Modified", "Editor")
    Add-PnPView -List $listName -Title "Project View" -Fields $fields -SetAsDefault
    Write-Host "✓ Created 'Project View'" -ForegroundColor Green
}

# Approved Documents View
$viewExists = Get-PnPView -List $listName -Identity "Approved Documents" -ErrorAction SilentlyContinue
if (!$viewExists) {
    $fields = @("DocIcon", "LinkFilename", "Project", "DocumentStatus", "Modified")
    Add-PnPView -List $listName -Title "Approved Documents" -Fields $fields -Query "<Where><Eq><FieldRef Name='DocumentStatus'/><Value Type='Choice'>Approved</Value></Eq></Where>"
    Write-Host "✓ Created 'Approved Documents' view" -ForegroundColor Green
}

# ============================================
# 2. Create Projects List
# ============================================
Write-Host "`nCreating Projects list..." -ForegroundColor Yellow
$projectsList = "Projects"
$list = Get-PnPList -Identity $projectsList -ErrorAction SilentlyContinue

if (!$list) {
    New-PnPList -Title $projectsList -Template GenericList
    Write-Host "✓ Projects list created" -ForegroundColor Green
} else {
    Write-Host "✓ Projects list already exists" -ForegroundColor Gray
}

# Add columns to Projects list
$field = Get-PnPField -List $projectsList -Identity "ProjectCode" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $projectsList -DisplayName "Project Code" -InternalName "ProjectCode" -Type Text -AddToDefaultView
}

$field = Get-PnPField -List $projectsList -Identity "ProjectPriority" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $projectsList -DisplayName "Priority" -InternalName "ProjectPriority" -Type Choice `
        -Choices "High","Medium","Low" -AddToDefaultView
}

$field = Get-PnPField -List $projectsList -Identity "ProjectStatus" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $projectsList -DisplayName "Status" -InternalName "ProjectStatus" -Type Choice `
        -Choices "Active","On Hold","Completed","Cancelled" -AddToDefaultView
}

$field = Get-PnPField -List $projectsList -Identity "StartDate" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $projectsList -DisplayName "Start Date" -InternalName "StartDate" -Type DateTime -AddToDefaultView
}

$field = Get-PnPField -List $projectsList -Identity "EndDate" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $projectsList -DisplayName "End Date" -InternalName "EndDate" -Type DateTime -AddToDefaultView
}

# Add sample projects
Write-Host "Adding sample projects..." -ForegroundColor Yellow
$sampleProjects = @(
    @{Title="SpaceX Project"; ProjectCode="SPX-001"; ProjectPriority="High"; ProjectStatus="Active"},
    @{Title="Tesla Project"; ProjectCode="TSL-002"; ProjectPriority="Medium"; ProjectStatus="Active"},
    @{Title="NVIDIA Project"; ProjectCode="NVD-003"; ProjectPriority="High"; ProjectStatus="Active"}
)

foreach ($proj in $sampleProjects) {
    $existing = Get-PnPListItem -List $projectsList -Query "<View><Query><Where><Eq><FieldRef Name='Title'/><Value Type='Text'>$($proj.Title)</Value></Eq></Where></Query></View>"
    if ($existing.Count -eq 0) {
        Add-PnPListItem -List $projectsList -Values $proj | Out-Null
        Write-Host "✓ Added project: $($proj.Title)" -ForegroundColor Green
    }
}

# ============================================
# 3. Create Signature Workflows List
# ============================================
Write-Host "`nCreating Signature Workflows list..." -ForegroundColor Yellow
$workflowsList = "Signature Workflows"
$list = Get-PnPList -Identity $workflowsList -ErrorAction SilentlyContinue

if (!$list) {
    New-PnPList -Title $workflowsList -Template GenericList
    Write-Host "✓ Signature Workflows list created" -ForegroundColor Green
} else {
    Write-Host "✓ Signature Workflows list already exists" -ForegroundColor Gray
}

# Add columns
$field = Get-PnPField -List $workflowsList -Identity "WorkflowStatus" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $workflowsList -DisplayName "Status" -InternalName "WorkflowStatus" -Type Choice `
        -Choices "Pending","In Progress","Completed","Rejected" -AddToDefaultView
}

$field = Get-PnPField -List $workflowsList -Identity "WorkflowPriority" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $workflowsList -DisplayName "Priority" -InternalName "WorkflowPriority" -Type Choice `
        -Choices "High","Medium","Low" -AddToDefaultView
}

$field = Get-PnPField -List $workflowsList -Identity "DueDate" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $workflowsList -DisplayName "Due Date" -InternalName "DueDate" -Type DateTime -AddToDefaultView
}

$field = Get-PnPField -List $workflowsList -Identity "CurrentApprover" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $workflowsList -DisplayName "Current Approver" -InternalName "CurrentApprover" -Type User -AddToDefaultView
}

$field = Get-PnPField -List $workflowsList -Identity "WorkflowStage" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $workflowsList -DisplayName "Workflow Stage" -InternalName "WorkflowStage" -Type Number
}

$field = Get-PnPField -List $workflowsList -Identity "Comments" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $workflowsList -DisplayName "Comments" -InternalName "Comments" -Type Note
}

# ============================================
# 4. Create Signature Steps List
# ============================================
Write-Host "`nCreating Signature Steps list..." -ForegroundColor Yellow
$stepsList = "Signature Steps"
$list = Get-PnPList -Identity $stepsList -ErrorAction SilentlyContinue

if (!$list) {
    New-PnPList -Title $stepsList -Template GenericList
    Write-Host "✓ Signature Steps list created" -ForegroundColor Green
} else {
    Write-Host "✓ Signature Steps list already exists" -ForegroundColor Gray
}

# Add columns
$field = Get-PnPField -List $stepsList -Identity "StepNumber" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $stepsList -DisplayName "Step Number" -InternalName "StepNumber" -Type Number -AddToDefaultView
}

$field = Get-PnPField -List $stepsList -Identity "Approver" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $stepsList -DisplayName "Approver" -InternalName "Approver" -Type User -AddToDefaultView
}

$field = Get-PnPField -List $stepsList -Identity "StepStatus" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $stepsList -DisplayName "Status" -InternalName "StepStatus" -Type Choice `
        -Choices "Pending","Approved","Rejected" -AddToDefaultView
}

$field = Get-PnPField -List $stepsList -Identity "SignedDate" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $stepsList -DisplayName "Signed Date" -InternalName "SignedDate" -Type DateTime -AddToDefaultView
}

$field = Get-PnPField -List $stepsList -Identity "StepComments" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $stepsList -DisplayName "Comments" -InternalName "StepComments" -Type Note
}

# ============================================
# 5. Create Forms List
# ============================================
Write-Host "`nCreating Forms list..." -ForegroundColor Yellow
$formsList = "Forms"
$list = Get-PnPList -Identity $formsList -ErrorAction SilentlyContinue

if (!$list) {
    New-PnPList -Title $formsList -Template GenericList
    Write-Host "✓ Forms list created" -ForegroundColor Green
} else {
    Write-Host "✓ Forms list already exists" -ForegroundColor Gray
}

# Add columns
$field = Get-PnPField -List $formsList -Identity "FormStatus" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $formsList -DisplayName "Status" -InternalName "FormStatus" -Type Choice `
        -Choices "Pending","Signed","Rejected" -AddToDefaultView
}

$field = Get-PnPField -List $formsList -Identity "FormType" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $formsList -DisplayName "Form Type" -InternalName "FormType" -Type Choice `
        -Choices "Budget Authorization","Change Request","Procurement","Risk Assessment","Compliance Checklist" -AddToDefaultView
}

$field = Get-PnPField -List $formsList -Identity "AssignedTo" -ErrorAction SilentlyContinue
if (!$field) {
    Add-PnPField -List $formsList -DisplayName "Assigned To" -InternalName "AssignedTo" -Type User -AddToDefaultView
}

# ============================================
# Final Summary
# ============================================
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "DMS Configuration Completed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

Write-Host "`nCreated Lists:" -ForegroundColor Cyan
Write-Host "  ✓ DMS Documents (Document Library)" -ForegroundColor White
Write-Host "  ✓ Projects" -ForegroundColor White
Write-Host "  ✓ Signature Workflows" -ForegroundColor White
Write-Host "  ✓ Signature Steps" -ForegroundColor White
Write-Host "  ✓ Forms" -ForegroundColor White

Write-Host "`nNext Steps:" -ForegroundColor Cyan
Write-Host "  1. Upload sample documents to DMS Documents library" -ForegroundColor White
Write-Host "  2. Create Power Automate flows for signature workflows" -ForegroundColor White
Write-Host "  3. Configure permissions as needed" -ForegroundColor White
Write-Host "  4. Connect your HTML front-end using REST API or Graph API" -ForegroundColor White

Write-Host "`nSite URL: $siteUrl" -ForegroundColor Yellow
Write-Host "`nScript execution completed successfully!" -ForegroundColor Green

# Disconnect
Disconnect-PnPOnline
