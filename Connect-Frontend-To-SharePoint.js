// ============================================
// SharePoint REST API Connection
// For connecting the HTML front-end to SharePoint
// ============================================

// SharePoint Configuration
const SHAREPOINT_CONFIG = {
    siteUrl: 'https://ofekpoint.sharepoint.com/sites/AITECH',
    listName: 'DMS Documents',
    projectsList: 'Projects',
    workflowsList: 'Signature Workflows'
};

// ============================================
// Helper Functions
// ============================================

// Get request digest for POST/UPDATE operations
async function getRequestDigest() {
    const response = await fetch(`${SHAREPOINT_CONFIG.siteUrl}/_api/contextinfo`, {
        method: 'POST',
        headers: {
            'Accept': 'application/json;odata=verbose',
            'Content-Type': 'application/json;odata=verbose'
        },
        credentials: 'include'
    });
    const data = await response.json();
    return data.d.GetContextWebInformation.FormDigestValue;
}

// ============================================
// Document Operations
// ============================================

// Get all documents
async function getAllDocuments() {
    try {
        const response = await fetch(
            `${SHAREPOINT_CONFIG.siteUrl}/_api/web/lists/getbytitle('${SHAREPOINT_CONFIG.listName}')/items?` +
            `$select=*,Author/Title,Editor/Title&$expand=Author,Editor&$top=100`,
            {
                headers: {
                    'Accept': 'application/json;odata=verbose'
                },
                credentials: 'include'
            }
        );
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const data = await response.json();
        return data.d.results;
    } catch (error) {
        console.error('Error fetching documents:', error);
        return [];
    }
}

// Get documents by project
async function getDocumentsByProject(projectName) {
    try {
        const response = await fetch(
            `${SHAREPOINT_CONFIG.siteUrl}/_api/web/lists/getbytitle('${SHAREPOINT_CONFIG.listName}')/items?` +
            `$select=*,Author/Title,Editor/Title&$expand=Author,Editor&` +
            `$filter=Project eq '${projectName}'`,
            {
                headers: {
                    'Accept': 'application/json;odata=verbose'
                },
                credentials: 'include'
            }
        );
        
        const data = await response.json();
        return data.d.results;
    } catch (error) {
        console.error('Error fetching project documents:', error);
        return [];
    }
}

// Update document metadata
async function updateDocument(itemId, updates) {
    try {
        const digest = await getRequestDigest();
        
        const metadata = {
            '__metadata': { 'type': 'SP.Data.DMS_x0020_DocumentsItem' }
        };
        
        // Merge updates into metadata
        Object.assign(metadata, updates);
        
        const response = await fetch(
            `${SHAREPOINT_CONFIG.siteUrl}/_api/web/lists/getbytitle('${SHAREPOINT_CONFIG.listName}')/items(${itemId})`,
            {
                method: 'POST',
                headers: {
                    'Accept': 'application/json;odata=verbose',
                    'Content-Type': 'application/json;odata=verbose',
                    'X-RequestDigest': digest,
                    'X-HTTP-Method': 'MERGE',
                    'IF-MATCH': '*'
                },
                body: JSON.stringify(metadata),
                credentials: 'include'
            }
        );
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        return { success: true, message: 'Document updated successfully' };
    } catch (error) {
        console.error('Error updating document:', error);
        return { success: false, error: error.message };
    }
}

// Upload document
async function uploadDocument(file, folderPath = '', metadata = {}) {
    try {
        const digest = await getRequestDigest();
        const fileName = file.name;
        
        // Upload file
        const uploadUrl = folderPath 
            ? `${SHAREPOINT_CONFIG.siteUrl}/_api/web/lists/getbytitle('${SHAREPOINT_CONFIG.listName}')/RootFolder/Folders('${folderPath}')/Files/add(url='${fileName}',overwrite=true)`
            : `${SHAREPOINT_CONFIG.siteUrl}/_api/web/lists/getbytitle('${SHAREPOINT_CONFIG.listName}')/RootFolder/Files/add(url='${fileName}',overwrite=true)`;
        
        const uploadResponse = await fetch(uploadUrl, {
            method: 'POST',
            headers: {
                'Accept': 'application/json;odata=verbose',
                'X-RequestDigest': digest
            },
            body: file,
            credentials: 'include'
        });
        
        const uploadData = await uploadResponse.json();
        const itemId = uploadData.d.ListItemAllFields.Id;
        
        // Update metadata if provided
        if (Object.keys(metadata).length > 0) {
            await updateDocument(itemId, metadata);
        }
        
        return { success: true, itemId: itemId };
    } catch (error) {
        console.error('Error uploading document:', error);
        return { success: false, error: error.message };
    }
}

// ============================================
// Project Operations
// ============================================

// Get all projects
async function getAllProjects() {
    try {
        const response = await fetch(
            `${SHAREPOINT_CONFIG.siteUrl}/_api/web/lists/getbytitle('${SHAREPOINT_CONFIG.projectsList}')/items`,
            {
                headers: {
                    'Accept': 'application/json;odata=verbose'
                },
                credentials: 'include'
            }
        );
        
        const data = await response.json();
        return data.d.results;
    } catch (error) {
        console.error('Error fetching projects:', error);
        return [];
    }
}

// Create new project
async function createProject(projectData) {
    try {
        const digest = await getRequestDigest();
        
        const metadata = {
            '__metadata': { 'type': 'SP.Data.ProjectsListItem' },
            'Title': projectData.title,
            'ProjectCode': projectData.code,
            'ProjectPriority': projectData.priority,
            'ProjectStatus': projectData.status
        };
        
        const response = await fetch(
            `${SHAREPOINT_CONFIG.siteUrl}/_api/web/lists/getbytitle('${SHAREPOINT_CONFIG.projectsList}')/items`,
            {
                method: 'POST',
                headers: {
                    'Accept': 'application/json;odata=verbose',
                    'Content-Type': 'application/json;odata=verbose',
                    'X-RequestDigest': digest
                },
                body: JSON.stringify(metadata),
                credentials: 'include'
            }
        );
        
        const data = await response.json();
        return { success: true, project: data.d };
    } catch (error) {
        console.error('Error creating project:', error);
        return { success: false, error: error.message };
    }
}

// ============================================
// Signature Workflow Operations
// ============================================

// Get pending signature requests for current user
async function getMyPendingSignatures() {
    try {
        const response = await fetch(
            `${SHAREPOINT_CONFIG.siteUrl}/_api/web/lists/getbytitle('${SHAREPOINT_CONFIG.workflowsList}')/items?` +
            `$filter=WorkflowStatus eq 'Pending' or WorkflowStatus eq 'In Progress'`,
            {
                headers: {
                    'Accept': 'application/json;odata=verbose'
                },
                credentials: 'include'
            }
        );
        
        const data = await response.json();
        return data.d.results;
    } catch (error) {
        console.error('Error fetching signature requests:', error);
        return [];
    }
}

// Create signature workflow
async function createSignatureWorkflow(workflowData) {
    try {
        const digest = await getRequestDigest();
        
        const metadata = {
            '__metadata': { 'type': 'SP.Data.Signature_x0020_WorkflowsListItem' },
            'Title': workflowData.title,
            'WorkflowStatus': 'Pending',
            'WorkflowPriority': workflowData.priority,
            'DueDate': workflowData.dueDate
        };
        
        const response = await fetch(
            `${SHAREPOINT_CONFIG.siteUrl}/_api/web/lists/getbytitle('${SHAREPOINT_CONFIG.workflowsList}')/items`,
            {
                method: 'POST',
                headers: {
                    'Accept': 'application/json;odata=verbose',
                    'Content-Type': 'application/json;odata=verbose',
                    'X-RequestDigest': digest
                },
                body: JSON.stringify(metadata),
                credentials: 'include'
            }
        );
        
        const data = await response.json();
        return { success: true, workflow: data.d };
    } catch (error) {
        console.error('Error creating workflow:', error);
        return { success: false, error: error.message };
    }
}

// ============================================
// Example Usage in your existing code
// ============================================

// Replace your showToast functions with actual SharePoint calls:

// Example 1: Load documents when page loads
window.addEventListener('DOMContentLoaded', async () => {
    console.log('Loading documents from SharePoint...');
    
    // Uncomment when ready to connect:
    // const documents = await getAllDocuments();
    // console.log('Loaded documents:', documents);
    // displayDocuments(documents);
});

// Example 2: Update document status
async function markDocumentAsApproved(itemId) {
    const result = await updateDocument(itemId, {
        'DocumentStatus': 'Approved',
        'Notes': 'Approved by manager'
    });
    
    if (result.success) {
        showToast('Document approved successfully', 'success');
    } else {
        showToast('Error approving document', 'error');
    }
}

// Example 3: Upload file with metadata
async function handleFileUpload(fileInput) {
    const file = fileInput.files[0];
    if (!file) return;
    
    const result = await uploadDocument(file, 'Projects', {
        'Project': 'SpaceX Project',
        'DocumentStatus': 'Draft',
        'Priority': 'High',
        'Client': 'SpaceX Inc.'
    });
    
    if (result.success) {
        showToast('File uploaded successfully', 'success');
    } else {
        showToast('Error uploading file', 'error');
    }
}

// Example 4: Get documents for library page
async function loadLibraryDocuments() {
    const documents = await getAllDocuments();
    
    // Build table rows
    const tbody = document.querySelector('.doc-table tbody');
    tbody.innerHTML = '';
    
    documents.forEach(doc => {
        const row = `
            <tr>
                <td><input type="checkbox"></td>
                <td><i class="fas fa-file-pdf"></i> ${doc.FileLeafRef}</td>
                <td><span class="version-badge">${doc.VersionNumber || 'v1.0'}</span></td>
                <td><span class="status-badge">${doc.DocumentStatus}</span></td>
                <td>${doc.Editor.Title}</td>
                <td>${new Date(doc.Modified).toLocaleDateString()}</td>
                <td>${doc.Project || ''}</td>
                <td><input type="text" class="note-input" value="${doc.Notes || ''}" placeholder="Add note..."></td>
                <td>
                    <button class="tbl-btn" onclick="openDocument(${doc.Id})">Open</button>
                </td>
            </tr>
        `;
        tbody.innerHTML += row;
    });
}

// ============================================
// Export functions for use in other files
// ============================================
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        getAllDocuments,
        getDocumentsByProject,
        updateDocument,
        uploadDocument,
        getAllProjects,
        createProject,
        getMyPendingSignatures,
        createSignatureWorkflow
    };
}
