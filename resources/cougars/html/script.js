let hudData = {
    progress: 0,
    cougarCount: 0,
    totalKills: 0,
    totalDeaths: 0,
    players: []
};

// Chaos Mod HTTP functionality
let currentPort = null;

// Listen for NUI messages from Lua
window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'updateHUD') {
        updateHUD(data);
    } else if (data.action === 'showHUD') {
        $('#hud-container').fadeIn();
    } else if (data.action === 'hideHUD') {
        $('#hud-container').fadeOut();
    } else if (data.action === 'setPort') {
        currentPort = data.port;
    } else if (data.action === 'triggerEffect') {
        // Call the original effect triggering function
        triggerChaosEffect(data.effectId, data.duration, data.timestamp);
    } else if (data.action === 'getStatus') {
        getChaosModStatus();
    } else if (data.action === 'toggleChaos') {
        toggleChaosMod();
    } else if (data.action === 'testConnection') {
        testConnection();
    }
});

function updateHUD(data) {
    // Update progress
    if (data.progress !== undefined) {
        hudData.progress = data.progress;
        $('#progress-bar').css('width', data.progress + '%');
        $('#progress-text').text(Math.round(data.progress) + '%');
    }
    
    // Update cougar count
    if (data.cougarCount !== undefined) {
        hudData.cougarCount = data.cougarCount;
        $('#cougar-count').text(data.cougarCount);
    }
    
    // Update kills
    if (data.totalKills !== undefined) {
        hudData.totalKills = data.totalKills;
        $('#total-kills').text(data.totalKills);
    }
    
    // Update deaths
    if (data.totalDeaths !== undefined) {
        hudData.totalDeaths = data.totalDeaths;
        $('#total-deaths').text(data.totalDeaths);
    }
    
    // Update player list
    if (data.players) {
        updatePlayerList(data.players);
    }
}

function updatePlayerList(players) {
    const container = $('#players-container');
    container.empty();
    
    players.forEach(player => {
        const playerDiv = $('<div>').addClass('player-item');
        if (!player.alive) {
            playerDiv.addClass('player-dead');
        }
        
        // Player name
        const nameDiv = $('<div>').addClass('player-name').text(player.name);
        playerDiv.append(nameDiv);
        
        // Player stats
        const statsDiv = $('<div>').addClass('player-stats');
        statsDiv.append(`<div class="player-stat">Kills: <span>${player.kills}</span></div>`);
        statsDiv.append(`<div class="player-stat">Deaths: <span>${player.deaths}</span></div>`);
        playerDiv.append(statsDiv);
        
        // Health bar
        const healthBar = $('<div>').addClass('health-bar');
        const healthFill = $('<div>').addClass('health-fill').css('width', player.health + '%');
        healthBar.append(healthFill);
        playerDiv.append(healthBar);
        
        // Ammo bar
        const ammoBar = $('<div>').addClass('ammo-bar');
        const ammoFill = $('<div>').addClass('ammo-fill').css('width', player.ammo + '%');
        ammoBar.append(ammoFill);
        playerDiv.append(ammoBar);
        
        container.append(playerDiv);
    });
}

// Function to trigger chaos effect via HTTP
function triggerChaosEffect(effectId, duration, timestamp) {
    if (!currentPort) {
        console.error('No port configured for Chaos Mod');
        return;
    }
    
    const url = `http://127.0.0.1:${currentPort}/trigger`;
    const requestData = {
        effectId: effectId,
        duration: duration,
        timestamp: timestamp
    };
    
    fetch(url, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(requestData)
    })
    .then(response => response.json())
    .then(result => {
        // Send response back to Lua
        fetch(`https://cougars/chaosResponse`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                success: result.success,
                effectId: effectId,
                error: result.error
            })
        });
    })
    .catch(error => {
        console.error('Error triggering chaos effect:', error);
        
        // Send error response back to Lua
        fetch(`https://cougars/chaosResponse`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                success: false,
                effectId: effectId,
                error: error.message
            })
        });
    });
}

// Function to get chaos mod status
function getChaosModStatus() {
    if (!currentPort) {
        console.error('No port configured for Chaos Mod');
        fetch(`https://cougars/chaosStatusResponse`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                chaos_mod_active: false
            })
        });
        return;
    }
    
    const url = `http://127.0.0.1:${currentPort}/status`;
    
    fetch(url, {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json'
        }
    })
    .then(response => response.json())
    .then(result => {
        // Send response back to Lua
        fetch(`https://cougars/chaosStatusResponse`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                chaos_mod_active: result.chaos_mod_active,
                current_effect: result.current_effect,
                time_remaining: result.time_remaining
            })
        });
    })
    .catch(error => {
        console.error('Error getting chaos mod status:', error);
        fetch(`https://cougars/chaosStatusResponse`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                chaos_mod_active: false,
                error: error.message
            })
        });
    });
}

// Function to toggle chaos mod
function toggleChaosMod() {
    if (!currentPort) {
        console.error('No port configured for Chaos Mod');
        return;
    }
    
    const url = `http://127.0.0.1:${currentPort}/toggle`;
    
    fetch(url, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        }
    })
    .then(response => response.json())
    .then(result => {
        // Send response back to Lua
        fetch(`https://cougars/chaosToggleResponse`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                success: result.success,
                chaos_mod_active: result.chaos_mod_active,
                message: result.message
            })
        });
    })
    .catch(error => {
        console.error('Error toggling chaos mod:', error);
    });
}

// Test connection function
function testConnection() {
    if (!currentPort) {
        console.error('No port configured for Chaos Mod');
        return;
    }
    
    const url = `http://127.0.0.1:${currentPort}/status`;
    
    fetch(url, {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json'
        }
    })
    .then(response => response.json())
    .then(result => {
        console.log('Chaos Mod connection test successful:', result);
    })
    .catch(error => {
        console.error('Chaos Mod connection test failed:', error);
    });
}
