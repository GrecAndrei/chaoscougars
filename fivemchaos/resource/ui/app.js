(function () {
  'use strict';

  var timerBar      = document.getElementById('timer-bar');
  var timerFill     = document.getElementById('timer-fill');
  var timerLabel    = document.getElementById('timer-label');
  var effectsList   = document.getElementById('effects-list');
  var hitContainer  = document.getElementById('hit-container');
  var cougarCounter = document.getElementById('cougar-counter');
  var cougarCount   = document.getElementById('cougar-count');
  var phaseOverlay  = document.getElementById('phase-overlay');
  var phaseText     = document.getElementById('phase-text');
  var adminPanel    = document.getElementById('admin-panel');
  var panelClose    = document.getElementById('panel-close');
  var effectInput   = document.getElementById('effect-input');
  var statPhase     = document.getElementById('stat-phase');
  var statDiff      = document.getElementById('stat-diff');
  var statCougars   = document.getElementById('stat-cougars');

  var MAX_EFFECTS = 5;
  var activeEffects = new Map();
  var tickInterval = null;
  var panelOpen = false;

  // ============== EFFECT TICKER ==============
  function startEffectTick() {
    if (tickInterval) return;
    tickInterval = setInterval(function () {
      var now = Date.now();
      activeEffects.forEach(function (entry, id) {
        if (entry.expiresAt <= now) {
          if (entry.el.parentNode) {
            entry.el.classList.add('removing');
            setTimeout(function () { if (entry.el.parentNode) entry.el.parentNode.removeChild(entry.el); }, 280);
          }
          activeEffects.delete(id);
        } else {
          entry.timeEl.textContent = Math.ceil((entry.expiresAt - now) / 1000) + 's';
        }
      });
      if (activeEffects.size === 0) {
        clearInterval(tickInterval);
        tickInterval = null;
      }
    }, 250);
  }

  function addEffect(id, name, duration) {
    if (!id || !name || duration <= 0) return;
    if (activeEffects.has(id)) {
      var existing = activeEffects.get(id);
      existing.expiresAt = Date.now() + duration * 1000;
      existing.timeEl.textContent = duration + 's';
      return;
    }
    var card = document.createElement('div');
    card.className = 'effect-card';
    var nameEl = document.createElement('span');
    nameEl.className = 'effect-name';
    nameEl.textContent = name;
    var timeEl = document.createElement('span');
    timeEl.className = 'effect-time';
    timeEl.textContent = duration + 's';
    card.appendChild(nameEl);
    card.appendChild(timeEl);
    effectsList.appendChild(card);
    activeEffects.set(id, { el: card, timeEl: timeEl, expiresAt: Date.now() + duration * 1000 });
    while (effectsList.children.length > MAX_EFFECTS) {
      effectsList.removeChild(effectsList.firstChild);
    }
    startEffectTick();
  }

  // ============== TIMER ==============
  function updateTimer(remaining, total) {
    if (!total || total <= 0) { timerBar.classList.add('hidden'); return; }
    timerBar.classList.remove('hidden');
    var progress = Math.max(0, Math.min(1, remaining / total));
    timerFill.style.width = (progress * 100) + '%';
    timerLabel.textContent = Math.ceil(remaining) + 's';
    if (progress < 0.2) { timerBar.classList.add('urgent'); }
    else { timerBar.classList.remove('urgent'); }
  }

  // ============== COUGARS ==============
  function updateCougars(count) {
    var c = Math.max(0, Math.floor(Number(count) || 0));
    statCougars.textContent = String(c);
    if (c <= 0) { cougarCounter.classList.add('hidden'); return; }
    cougarCounter.classList.remove('hidden');
    cougarCount.textContent = String(c);
  }

  // ============== PHASE ==============
  function updatePhase(phase) {
    statPhase.textContent = phase || 'LOBBY';
    if (phase === 'WON') {
      phaseOverlay.classList.remove('hidden', 'lost');
      phaseOverlay.classList.add('won');
      phaseText.textContent = 'VICTORY';
    } else if (phase === 'LOST') {
      phaseOverlay.classList.remove('hidden', 'won');
      phaseOverlay.classList.add('lost');
      phaseText.textContent = 'WASTED';
    } else {
      phaseOverlay.classList.add('hidden');
      phaseOverlay.classList.remove('won', 'lost');
      phaseText.textContent = '';
    }
  }

  // ============== HITS ==============
  function showHit(text) {
    if (!text) return;
    var el = document.createElement('div');
    el.className = 'hit-notification';
    el.textContent = text;
    hitContainer.appendChild(el);
    setTimeout(function () { if (el.parentNode) el.parentNode.removeChild(el); }, 1500);
  }

  // ============== ADMIN PANEL ==============
  function togglePanel(show) {
    panelOpen = (typeof show === 'boolean') ? show : !panelOpen;
    if (panelOpen) {
      adminPanel.classList.remove('hidden');
    } else {
      adminPanel.classList.add('hidden');
    }
    fetch('https://cougars/panel_toggle', {
      method: 'POST',
      body: JSON.stringify({ open: panelOpen })
    }).catch(function(){});
  }

  panelClose.addEventListener('click', function () { togglePanel(false); });

  // Button actions
  adminPanel.addEventListener('click', function (e) {
    var btn = e.target.closest('[data-action]');
    if (btn) {
      fetch('https://cougars/panel_action', {
        method: 'POST',
        body: JSON.stringify({ action: btn.dataset.action })
      }).catch(function(){});
      return;
    }
    var efxBtn = e.target.closest('[data-effect]');
    if (efxBtn) {
      fetch('https://cougars/panel_effect', {
        method: 'POST',
        body: JSON.stringify({ id: efxBtn.dataset.effect })
      }).catch(function(){});
    }
  });

  // Custom effect input (Enter key)
  effectInput.addEventListener('keydown', function (e) {
    if (e.key === 'Enter' && effectInput.value.trim()) {
      fetch('https://cougars/panel_effect', {
        method: 'POST',
        body: JSON.stringify({ id: effectInput.value.trim() })
      }).catch(function(){});
      effectInput.value = '';
    }
  });

  // ============== NUI MESSAGE HANDLER ==============
  window.addEventListener('message', function (event) {
    var data = event.data;
    if (!data || typeof data !== 'object') return;

    switch (data.type) {
      case 'timer':
        updateTimer(data.remaining, data.total);
        break;
      case 'effect':
        addEffect(data.id, data.name, data.duration || 0);
        break;
      case 'effects_cleared':
        activeEffects.forEach(function (entry) {
          if (entry.el.parentNode) entry.el.parentNode.removeChild(entry.el);
        });
        activeEffects.clear();
        break;
      case 'hit':
        showHit(data.variant);
        break;
      case 'cougars':
        updateCougars(data.count);
        break;
      case 'state':
      case 'phase':
        updatePhase(data.phase);
        break;
      case 'mission_start':
        updatePhase('RUNNING');
        break;
      case 'mission_end':
        updatePhase(data.result);
        break;
      case 'death':
        showHit('WASTED');
        break;
      case 'difficulty':
        statDiff.textContent = Math.round((data.value || 0) * 100) + '%';
        break;
      case 'panel_toggle':
        togglePanel(data.open);
        break;
    }
  });

})();
