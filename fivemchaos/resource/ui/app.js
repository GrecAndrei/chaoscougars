(function () {
  'use strict';

  var byId = function (id) { return document.getElementById(id); };
  var hud = byId('hud');
  var timerBar = byId('timer-bar');
  var timerFill = byId('timer-fill');
  var timerLabel = byId('timer-label');
  var effectsTitle = byId('effects-title');
  var effectsList = byId('effects-list');
  var cougarCounter = byId('cougar-counter');
  var cougarCount = byId('cougar-count');
  var votePanel = byId('vote-panel');
  var voteTime = byId('vote-time');
  var voteOptions = byId('vote-options');
  var notices = byId('hit-container');
  var phaseOverlay = byId('phase-overlay');
  var phaseText = byId('phase-text');
  var phaseSub = byId('phase-sub');
  var adminPanel = byId('admin-panel');
  var panelClose = byId('panel-close');
  var effectInput = byId('effect-input');
  var customEffectForm = byId('custom-effect-form');
  var statPhase = byId('stat-phase');
  var statDiff = byId('stat-diff');
  var statCougars = byId('stat-cougars');

  var MAX_EFFECTS = 5;
  var activeEffects = new Map();
  var effectTick = null;
  var voteTick = null;
  var phaseTimer = null;
  var panelOpen = false;

  function post(endpoint, payload) {
    try {
      fetch('https://cougars/' + endpoint, {
        method: 'POST',
        body: JSON.stringify(payload || {})
      }).catch(function () {});
    } catch (_) {}
  }

  function formatTime(seconds) {
    var value = Math.max(0, Math.ceil(Number(seconds) || 0));
    var minutes = Math.floor(value / 60);
    var remaining = value % 60;
    return minutes + ':' + String(remaining).padStart(2, '0');
  }

  function effectKind(name) {
    var text = String(name || '').toLowerCase();
    if (/cougar|spawn|meteor|airstrike|rain|storm|explode|fire|ignite|bomb/.test(text)) return 'danger';
    if (/gravity|weather|time|world|traffic|vehicle|prop/.test(text)) return 'world';
    if (/speed|jump|weapon|health|armor|drunk|lsd|ragdoll/.test(text)) return 'player';
    return '';
  }

  function setEffectsTitle() {
    effectsTitle.classList.toggle('hidden', activeEffects.size === 0);
  }

  function removeEffect(id, animated) {
    var entry = activeEffects.get(id);
    if (!entry) return;
    activeEffects.delete(id);
    if (entry.element.parentNode) {
      if (animated) {
        entry.element.classList.add('removing');
        setTimeout(function () { entry.element.remove(); }, 180);
      } else {
        entry.element.remove();
      }
    }
    setEffectsTitle();
  }

  function startEffectTick() {
    if (effectTick) return;
    effectTick = setInterval(function () {
      var now = Date.now();
      activeEffects.forEach(function (entry, id) {
        var seconds = (entry.endsAt - now) / 1000;
        if (seconds <= 0) removeEffect(id, true);
        else entry.time.textContent = formatTime(seconds);
      });
      if (activeEffects.size === 0) {
        clearInterval(effectTick);
        effectTick = null;
      }
    }, 250);
  }

  function addEffect(id, name, duration) {
    if (!id || !name || Number(duration) <= 0) return;
    var seconds = Number(duration);
    var existing = activeEffects.get(id);
    if (existing) {
      existing.endsAt = Date.now() + seconds * 1000;
      existing.time.textContent = formatTime(seconds);
      return;
    }

    var card = document.createElement('div');
    var kind = effectKind(name);
    card.className = 'effect-card' + (kind ? ' effect-card--' + kind : '');
    var marker = document.createElement('span');
    marker.className = 'effect-card__mark';
    var label = document.createElement('span');
    label.className = 'effect-card__name';
    label.textContent = String(name);
    var time = document.createElement('span');
    time.className = 'effect-card__time';
    time.textContent = formatTime(seconds);
    card.append(marker, label, time);
    effectsList.appendChild(card);
    activeEffects.set(id, { element: card, time: time, endsAt: Date.now() + seconds * 1000 });

    while (activeEffects.size > MAX_EFFECTS) {
      removeEffect(activeEffects.keys().next().value, false);
    }
    setEffectsTitle();
    startEffectTick();
  }

  function clearEffects() {
    activeEffects.forEach(function (_, id) { removeEffect(id, false); });
    if (effectTick) {
      clearInterval(effectTick);
      effectTick = null;
    }
    effectsList.replaceChildren();
    setEffectsTitle();
    timerBar.classList.add('hidden');
    timerFill.style.width = '0%';
    timerLabel.textContent = '--:--';
  }

  function updateTimer(remaining, total) {
    if (Number(total) <= 0) {
      timerBar.classList.add('hidden');
      return;
    }
    var progress = Math.max(0, Math.min(1, Number(remaining) / Number(total)));
    timerBar.classList.remove('hidden');
    timerBar.classList.toggle('urgent', progress <= .2);
    timerFill.style.width = (progress * 100) + '%';
    timerLabel.textContent = formatTime(remaining);
  }

  function updateCougars(count) {
    var value = Math.max(0, Math.floor(Number(count) || 0));
    cougarCount.textContent = String(value);
    statCougars.textContent = String(value);
    cougarCounter.classList.toggle('hidden', value === 0);
    cougarCounter.classList.toggle('danger', value >= 6);
    if (value > 0) {
      cougarCounter.classList.remove('pulse');
      void cougarCounter.offsetWidth;
      cougarCounter.classList.add('pulse');
    }
  }

  function showNotice(text) {
    if (!text) return;
    var notice = document.createElement('div');
    notice.className = 'notice';
    notice.textContent = text;
    notices.appendChild(notice);
    setTimeout(function () { notice.remove(); }, 1800);
  }

  function resetPhase() {
    if (phaseTimer) {
      clearTimeout(phaseTimer);
      phaseTimer = null;
    }
    phaseOverlay.className = 'phase-overlay';
    phaseText.textContent = '';
    phaseSub.textContent = '';
  }

  function updatePhase(phase, detail) {
    var state = String(phase || 'LOBBY').toUpperCase();
    statPhase.textContent = state;
    resetPhase();
    if (state === 'RUNNING') {
      phaseOverlay.classList.add('hidden');
      return;
    }

    var title = '';
    var subtitle = detail || '';
    if (state === 'WON') { title = 'RUN COMPLETE'; subtitle = subtitle || 'Paleto Bay reached'; phaseOverlay.classList.add('won'); }
    else if (state === 'LOST') { title = 'RUN FAILED'; subtitle = subtitle || 'The squad was overrun'; phaseOverlay.classList.add('lost'); }
    else if (state === 'PAUSED') { title = 'PAUSED'; phaseOverlay.classList.add('paused'); }
    else if (state === 'STARTING') { title = 'GET READY'; phaseOverlay.classList.add('lobby'); }
    else { title = 'WAITING FOR SQUAD'; phaseOverlay.classList.add('lobby'); }
    phaseText.textContent = title;
    phaseSub.textContent = subtitle;
    phaseOverlay.classList.remove('hidden');
  }

  function flashGo() {
    resetPhase();
    phaseOverlay.classList.add('go');
    phaseText.textContent = 'GO';
    phaseOverlay.classList.remove('hidden');
    phaseTimer = setTimeout(function () {
      phaseOverlay.classList.add('hidden');
      phaseTimer = null;
    }, 800);
  }

  function clearVote() {
    if (voteTick) {
      clearInterval(voteTick);
      voteTick = null;
    }
    if (votePanel.classList.contains('hidden')) return;
    votePanel.classList.add('fading');
    setTimeout(function () {
      voteOptions.replaceChildren();
      votePanel.classList.add('hidden');
      votePanel.classList.remove('fading');
    }, 160);
  }

  function showVote(options, timeLeft, threshold) {
    var maxVotes = Math.max(1, Number(threshold) || 1);
    voteOptions.replaceChildren();
    (Array.isArray(options) ? options : []).forEach(function (option, index) {
      var votes = Math.max(0, Number(option.votes) || 0);
      var row = document.createElement('div');
      row.className = 'vote-option';
      var key = document.createElement('span');
      key.className = 'vote-option__key';
      key.textContent = index + 1;
      var name = document.createElement('span');
      name.className = 'vote-option__name';
      name.textContent = String(option.name || 'Option');
      var tally = document.createElement('span');
      tally.className = 'vote-option__votes';
      tally.textContent = votes + '/' + maxVotes;
      row.append(key, name, tally);
      voteOptions.appendChild(row);
    });

    var seconds = Math.max(0, Math.ceil(Number(timeLeft) || 0));
    voteTime.textContent = formatTime(seconds);
    votePanel.classList.remove('hidden', 'fading');
    if (voteTick) clearInterval(voteTick);
    voteTick = setInterval(function () {
      seconds -= 1;
      if (seconds <= 0) clearVote();
      else voteTime.textContent = formatTime(seconds);
    }, 1000);
  }

  function togglePanel(open) {
    panelOpen = typeof open === 'boolean' ? open : !panelOpen;
    adminPanel.classList.toggle('hidden', !panelOpen);
    post('panel_toggle', { open: panelOpen });
  }

  panelClose.addEventListener('click', function () { togglePanel(false); });
  adminPanel.addEventListener('click', function (event) {
    var action = event.target.closest('[data-action]');
    if (action) post('panel_action', { action: action.dataset.action });
    var effect = event.target.closest('[data-effect]');
    if (effect) post('panel_effect', { id: effect.dataset.effect });
  });
  customEffectForm.addEventListener('submit', function (event) {
    event.preventDefault();
    var id = effectInput.value.trim();
    if (!id) return;
    post('panel_effect', { id: id });
    effectInput.value = '';
  });
  document.addEventListener('keydown', function (event) {
    if (event.key === 'Escape' && panelOpen) togglePanel(false);
  });

  window.addEventListener('message', function (event) {
    var data = event.data;
    if (!data || typeof data !== 'object') return;
    switch (data.type) {
      case 'timer': updateTimer(data.remaining, data.total); break;
      case 'effect': addEffect(data.id, data.name, data.duration); break;
      case 'effects_cleared': clearEffects(); break;
      case 'meta_ui':
        hud.classList.toggle('meta-hidden', Boolean(data.hidden));
        if (data.hidden) clearEffects();
        break;
      case 'hit': showNotice(data.variant); break;
      case 'cougars': updateCougars(data.count); break;
      case 'state':
      case 'phase': updatePhase(data.phase); break;
      case 'mission_start': flashGo(); break;
      case 'mission_end': updatePhase(data.result, data.detail); break;
      case 'death':
        showNotice((data.player || 'Someone') + ' KIA' + (typeof data.alive === 'number' ? ' — ' + data.alive + ' remaining' : ''));
        break;
      case 'difficulty': statDiff.textContent = Math.round(Math.max(0, Math.min(1, Number(data.value) || 0)) * 100) + '%'; break;
      case 'vote': showVote(data.options, data.timeLeft, data.threshold); break;
      case 'vote_end': clearVote(); break;
      case 'panel_toggle': togglePanel(data.open); break;
    }
  });

  post('ready', {});
})();
