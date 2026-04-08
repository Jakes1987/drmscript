/**
 * Kayo to O11V4 Script Generator - Frontend Application
 * Handles UI interactions and API communication
 */

// DOM Elements
const form = document.getElementById('generatorForm');
const testBtn = document.getElementById('testBtn');
const generateBtn = document.getElementById('generateBtn');
const resetBtn = document.getElementById('resetBtn');

const usernameInput = document.getElementById('username');
const passwordInput = document.getElementById('password');
const providerNameInput = document.getElementById('providerName');
const outputDirInput = document.getElementById('outputDir');
const includeConfigCheckbox = document.getElementById('includeConfig');

const statusDisplay = document.getElementById('statusDisplay');
const statusIcon = statusDisplay.querySelector('.status-icon');
const statusText = statusDisplay.querySelector('.status-text');
const progressFill = document.getElementById('progressFill');
const progressText = document.getElementById('progressText');
const messageArea = document.getElementById('messageArea');
const errorArea = document.getElementById('errorArea');
const resultsArea = document.getElementById('resultsArea');
const helpArea = document.getElementById('helpArea');

// Status management
let isProcessing = false;
const statusIcons = {
    idle: '⏳',
    processing: '⚙️',
    completed: '✓',
    error: '✕'
};

const statusMessages = {
    idle: 'Ready',
    processing: 'Processing...',
    completed: 'Generation Complete',
    error: 'Error Occurred'
};

/**
 * Update status display
 */
function updateStatusDisplay(status, progress = 0, message = '') {
    statusDisplay.className = `status-display ${status}`;
    statusIcon.textContent = statusIcons[status];
    statusText.textContent = statusMessages[status];
    
    if (progress !== undefined) {
        progressFill.style.width = `${progress}%`;
        progressText.textContent = `${progress}%`;
    }
    
    if (message) {
        messageArea.innerHTML = escapeHtml(message);
        messageArea.style.display = 'block';
    }
}

/**
 * Show error message
 */
function showError(error) {
    updateStatusDisplay('error');
    errorArea.innerHTML = `<strong>Error:</strong> ${escapeHtml(error)}`;
    errorArea.style.display = 'block';
    resultsArea.style.display = 'none';
    helpArea.style.display = 'block';
}

/**
 * Show success results
 */
function showResults(data) {
    resultsArea.style.display = 'block';
    helpArea.style.display = 'none';
    errorArea.style.display = 'none';
    
    document.getElementById('resultOutputDir').textContent = data.output_dir;
    
    const filesList = data.files
        .map(f => `<span class="file-badge">${escapeHtml(f)}</span>`)
        .join(' ');
    document.getElementById('resultFiles').innerHTML = filesList;
    
    document.getElementById('resultChannels').textContent = data.channels || 0;
    document.getElementById('resultEvents').textContent = data.events || 0;
    
    // Generate download links
    const downloadLinksHtml = data.files
        .map(filename => `
            <div class="download-link">
                <span class="download-link-name">${escapeHtml(filename)}</span>
                <button class="download-btn" onclick="downloadFile('${escapeHtml(filename)}')">
                    ⬇ Download
                </button>
            </div>
        `)
        .join('');
    document.getElementById('downloadLinks').innerHTML = downloadLinksHtml;
}

/**
 * Poll status until generation completes
 */
async function pollStatus(maxAttempts = 300) {
    let attempts = 0;
    
    while (attempts < maxAttempts) {
        try {
            const response = await fetch('/api/status');
            const status = await response.json();
            
            updateStatusDisplay(
                status.status,
                status.progress,
                status.message
            );
            
            if (status.status === 'completed') {
                showResults(status);
                generateBtn.disabled = false;
                isProcessing = false;
                return true;
            } else if (status.status === 'error') {
                showError(status.error || 'Unknown error occurred');
                generateBtn.disabled = false;
                isProcessing = false;
                return false;
            }
            
            await new Promise(resolve => setTimeout(resolve, 500));
            attempts++;
        } catch (err) {
            console.error('Status poll error:', err);
            await new Promise(resolve => setTimeout(resolve, 1000));
            attempts++;
        }
    }
    
    showError('Generation timeout - please try again');
    generateBtn.disabled = false;
    isProcessing = false;
    return false;
}

/**
 * Test credentials
 */
testBtn.addEventListener('click', async () => {
    const username = usernameInput.value.trim();
    const password = passwordInput.value.trim();
    
    if (!username || !password) {
        document.getElementById('testResult').textContent = 'Please enter both email and password';
        document.getElementById('testResult').className = 'test-result error';
        return;
    }
    
    if (isProcessing) return;
    
    testBtn.disabled = true;
    document.getElementById('testResult').innerHTML = '<span class="spinner"></span> Testing...';
    document.getElementById('testResult').className = 'test-result';
    
    try {
        const response = await fetch('/api/test-credentials', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ username, password })
        });
        
        const data = await response.json();
        
        if (data.success) {
            document.getElementById('testResult').textContent = '✓ ' + data.message;
            document.getElementById('testResult').className = 'test-result success';
        } else {
            document.getElementById('testResult').textContent = '✕ ' + data.message;
            document.getElementById('testResult').className = 'test-result error';
        }
    } catch (err) {
        document.getElementById('testResult').textContent = '✕ Connection error: ' + err.message;
        document.getElementById('testResult').className = 'test-result error';
    } finally {
        testBtn.disabled = false;
    }
});

/**
 * Generate script
 */
form.addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const username = usernameInput.value.trim();
    const password = passwordInput.value.trim();
    const providerName = providerNameInput.value.trim();
    const outputDir = outputDirInput.value.trim();
    
    if (!username || !password) {
        showError('Please enter your Kayo credentials');
        return;
    }
    
    if (!providerName) {
        showError('Please enter a provider name');
        return;
    }
    
    if (!outputDir) {
        showError('Please enter an output directory');
        return;
    }
    
    if (isProcessing) return;
    
    isProcessing = true;
    generateBtn.disabled = true;
    helpArea.style.display = 'none';
    resultsArea.style.display = 'none';
    errorArea.style.display = 'none';
    messageArea.innerHTML = '';
    
    updateStatusDisplay('processing', 5, 'Initializing...');
    
    try {
        const response = await fetch('/api/generate', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                username,
                password,
                provider_name: providerName,
                output_dir: outputDir,
                include_config: includeConfigCheckbox.checked
            })
        });
        
        const data = await response.json();
        
        if (data.success) {
            // Poll for completion
            await pollStatus();
        } else {
            showError(data.message || 'Generation failed');
            generateBtn.disabled = false;
            isProcessing = false;
        }
    } catch (err) {
        showError('Network error: ' + err.message);
        generateBtn.disabled = false;
        isProcessing = false;
    }
});

/**
 * Reset form
 */
resetBtn.addEventListener('click', async () => {
    try {
        await fetch('/api/reset', { method: 'POST' });
        
        // Reset UI
        updateStatusDisplay('idle', 0);
        resultsArea.style.display = 'none';
        errorArea.style.display = 'none';
        messageArea.innerHTML = '';
        helpArea.style.display = 'block';
        
        generateBtn.disabled = false;
        isProcessing = false;
        
        // Scroll to top
        window.scrollTo({ top: 0, behavior: 'smooth' });
    } catch (err) {
        console.error('Reset error:', err);
    }
});

/**
 * Download file
 */
function downloadFile(filename) {
    const link = document.createElement('a');
    link.href = `/api/download/${filename}`;
    link.download = filename;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
}

/**
 * Escape HTML to prevent XSS
 */
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

/**
 * Initialize on page load
 */
document.addEventListener('DOMContentLoaded', () => {
    // Check for auto-filled fields
    if (usernameInput.value) {
        usernameInput.focus();
    }
    
    // Restore last used values from localStorage if available
    try {
        const saved = JSON.parse(localStorage.getItem('kayoFormData'));
        if (saved) {
            if (saved.providerName) providerNameInput.value = saved.providerName;
            if (saved.outputDir) outputDirInput.value = saved.outputDir;
        }
    } catch (e) {
        // localStorage not available or corrupted
    }
    
    // Save form data to localStorage on change
    [providerNameInput, outputDirInput].forEach(input => {
        input.addEventListener('change', () => {
            try {
                const data = {
                    providerName: providerNameInput.value,
                    outputDir: outputDirInput.value
                };
                localStorage.setItem('kayoFormData', JSON.stringify(data));
            } catch (e) {
                // localStorage not available
            }
        });
    });
    
    console.log('Kayo to O11V4 Script Generator - GUI Ready');
});

/**
 * Handle form auto-fill for password managers
 */
document.addEventListener('change', (e) => {
    if (e.target === usernameInput || e.target === passwordInput) {
        // Clear test result when credentials change
        document.getElementById('testResult').textContent = '';
        document.getElementById('testResult').className = 'test-result';
    }
});

// Allow Enter key to test credentials from password input
passwordInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter' && !isProcessing) {
        e.preventDefault();
        testBtn.click();
    }
});

// Warn before leaving if processing
window.addEventListener('beforeunload', (e) => {
    if (isProcessing) {
        e.preventDefault();
        e.returnValue = '';
        return '';
    }
});
