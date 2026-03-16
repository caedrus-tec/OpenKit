// Memory Visualizer - Carga y renderiza YAMLs

// Utilizamos js-yaml cargado via CDN

// State
let contextData = null;
let projectStatusData = null;
let fullADRs = null;
let fullSessions = null;

// Tab handling
document.querySelectorAll('.tab').forEach(tab => {
  tab.addEventListener('click', () => {
    const targetTab = tab.dataset.tab;

    document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
    document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));

    tab.classList.add('active');
    document.getElementById(targetTab).classList.add('active');
  });
});

// Load data
async function loadData() {
  try {
    updateStatus('loading', 'Loading memory data...');

    // Load context.yaml
    try {
      const contextRes = await fetch('/context.yaml');
      const contextText = await contextRes.text();
      contextData = jsyaml.load(contextText);
    } catch (e) {
      console.warn('context.yaml not found - expected if not compiled yet');
    }

    // Load project-status.yaml
    try {
      const statusRes = await fetch('/project-status.yaml');
      const statusText = await statusRes.text();
      projectStatusData = jsyaml.load(statusText);
    } catch (e) {
      console.warn('project-status.yaml not found');
    }

    // Load full/adr.yaml
    try {
      const adrRes = await fetch('/full/adr.yaml');
      const adrText = await adrRes.text();
      fullADRs = jsyaml.load(adrText);
    } catch (e) {
      console.warn('full/adr.yaml not found');
    }

    // Load full/sessions.yaml
    try {
      const sessionsRes = await fetch('/full/sessions.yaml');
      const sessionsText = await sessionsRes.text();
      fullSessions = jsyaml.load(sessionsText);
    } catch (e) {
      console.warn('full/sessions.yaml not found');
    }

    renderAll();
    updateStatus('success', 'Memory loaded successfully');
  } catch (error) {
    updateStatus('error', `Error loading data: ${error.message}`);
    console.error(error);
  }
}

function updateStatus(type, message) {
  const dot = document.getElementById('statusDot');
  const text = document.getElementById('statusText');

  text.textContent = message;

  if (type === 'success') {
    dot.style.background = 'var(--success)';
  } else if (type === 'error') {
    dot.style.background = 'var(--error)';
  } else {
    dot.style.background = 'var(--warning)';
  }
}

function renderAll() {
  renderAgentView();
  renderFullHistory();
  renderProjectStatus();
  renderStats();
}

// Render Agent View (context.yaml)
function renderAgentView() {
  if (!contextData) {
    document.getElementById('agentProject').innerHTML = '<p class="error">context.yaml not found. Run Context Agent first.</p>';
    return;
  }

  // Project info
  const project = contextData.project || {};
  document.getElementById('agentProject').innerHTML = `
    <p><strong>Nombre:</strong> ${project.nombre || 'N/A'}</p>
    <p><strong>Descripción:</strong> ${project.descripcion || 'N/A'}</p>
    <p><strong>Fase:</strong> ${project.fase || 'N/A'}</p>
    <p><strong>Última feature:</strong> ${project.ultima_feature || 'N/A'}</p>
    <p><strong>Siguiente milestone:</strong> ${project.siguiente_milestone || 'N/A'}</p>
  `;

  // Features
  const features = contextData.features || {};
  const featuresHTML = Object.keys(features).map(key => {
    const f = features[key];
    return `
      <div class="feature-card">
        <span class="feature-status status-${f.estado || 'pendiente'}">${f.estado || 'pendiente'}</span>
        <h4>${f.nombre || key}</h4>
        <p>${f.descripcion || ''}</p>
        ${f.url ? `<p><a href="${f.url}" target="_blank">${f.url}</a></p>` : ''}
      </div>
    `;
  }).join('');
  document.getElementById('agentFeatures').innerHTML = featuresHTML || '<p>No features</p>';

  // ADRs
  const adrs = contextData.adrs || [];
  const adrsHTML = (Array.isArray(adrs) ? adrs : []).map(adr => `
    <div class="adr-card">
      <div class="adr-header">
        <div class="adr-title">ADR-${adr.id}: ${adr.titulo}</div>
      </div>
      <p><strong>Decisión:</strong> ${adr.decision}</p>
      <p><strong>Motivo:</strong> ${adr.motivo}</p>
      <p><strong>Impacto:</strong> ${adr.impacto}</p>
    </div>
  `).join('');
  document.getElementById('agentADRs').innerHTML = adrsHTML || '<p>No ADRs</p>';

  // Última sesión
  const session = contextData.ultima_sesion || {};
  const sessionHTML = `
    <p><strong>Fecha:</strong> ${session.data || 'N/A'}</p>
    <p><strong>Duración:</strong> ${session.duracion || 'N/A'}</p>
    ${session.que_se_hizo ? `
      <h4>Qué se hizo:</h4>
      <ul>${(Array.isArray(session.que_se_hizo) ? session.que_se_hizo : []).map(item => `<li>${item}</li>`).join('')}</ul>
    ` : ''}
    ${session.decisions ? `
      <h4>Decisiones:</h4>
      <ul>${(Array.isArray(session.decisions) ? session.decisions : []).map(item => `<li>${item}</li>`).join('')}</ul>
    ` : ''}
  `;
  document.getElementById('agentSession').innerHTML = sessionHTML;

  // Gotchas
  const gotchas = contextData.gotchas || [];
  const gotchasHTML = (Array.isArray(gotchas) ? gotchas : []).map(g => `
    <div class="gotcha-item">
      <strong>${g.id}:</strong> ${g.problema}<br>
      <em>Solución: ${g.solucio}</em>
    </div>
  `).join('');
  document.getElementById('agentGotchas').innerHTML = gotchasHTML || '<p>No gotchas</p>';

  // Pendientes
  const pendientes = contextData.pendientes || [];
  const pendientesHTML = (Array.isArray(pendientes) ? pendientes : []).map(p => `
    <div class="pendiente-item">
      <strong>P${p.prioritat}:</strong> ${p.tasca}<br>
      ${p.detall ? `<em>${p.detall}</em>` : ''}
    </div>
  `).join('');
  document.getElementById('agentPendents').innerHTML = pendientesHTML || '<p>No pendientes</p>';
}

// Render Full History
function renderFullHistory() {
  // Full ADRs
  if (fullADRs && fullADRs.adrs) {
    const adrsHTML = fullADRs.adrs.map(adr => `
      <div class="adr-card">
        <div class="adr-header">
          <div class="adr-title">ADR-${adr.id}: ${adr.titulo}</div>
          <span class="adr-badge badge-${adr.estado}">${adr.estado}</span>
        </div>
        <p><strong>Fecha:</strong> ${adr.data}</p>
        <p><strong>Área:</strong> ${adr.area}</p>
        <p>${adr.decision}</p>
      </div>
    `).join('');
    document.getElementById('fullADRs').innerHTML = adrsHTML;
  } else {
    document.getElementById('fullADRs').innerHTML = '<p class="error">full/adr.yaml not found</p>';
  }

  // Full Sessions
  if (fullSessions && fullSessions.sessions) {
    const sessionsHTML = fullSessions.sessions.map(session => {
      const featuresHTML = session.features_implementadas ?
        '<h4>Features Implementadas:</h4><ul>' +
        session.features_implementadas.map(f => `<li><strong>${f.nombre}:</strong> ${f.descripcion}</li>`).join('') +
        '</ul>' : '';

      const problemesHTML = session.problemas_resueltos ?
        '<h4>Problemas Resueltos:</h4><ul>' +
        session.problemas_resueltos.map(p => `<li><strong>${p.problema}:</strong> ${p.solucion}</li>`).join('') +
        '</ul>' : '';

      const decisionsHTML = session.decisiones_tomadas ?
        '<h4>Decisiones Tomadas:</h4><ul>' +
        session.decisiones_tomadas.map(d => {
          const adrLink = d.adr_relacionada ? ` <span class="adr-link">(ADR-${d.adr_relacionada})</span>` : '';
          return `<li><strong>${d.decision}:</strong> ${d.justificacion}${adrLink}</li>`;
        }).join('') +
        '</ul>' : '';

      const techHTML = session.tecnologias_agregadas ?
        '<h4>Tecnologías Añadidas:</h4><ul>' +
        session.tecnologias_agregadas.map(t => `<li><strong>${t.nombre}:</strong> ${t.motivo}</li>`).join('') +
        '</ul>' : '';

      const deploysHTML = session.deployments ?
        '<h4>Deployments:</h4><ul>' +
        session.deployments.map(d => `<li><strong>${d.servicio}:</strong> <a href="${d.url}" target="_blank">${d.url}</a></li>`).join('') +
        '</ul>' : '';

      const proximosHTML = session.proximos_pasos ?
        '<h4>Próximos Pasos:</h4><ul>' +
        session.proximos_pasos.map(p => `<li>${p}</li>`).join('') +
        '</ul>' : '';

      return `
        <div class="session-card">
          <h3>${session.titulo || session.id}</h3>
          <div class="session-meta">
            <span><strong>Fecha:</strong> ${session.data}</span>
            <span><strong>Duración:</strong> ${session.duracion}</span>
            <span><strong>Participantes:</strong> ${Array.isArray(session.participantes) ? session.participantes.join(', ') : session.participantes}</span>
          </div>
          <p class="session-objective"><strong>Objetivo:</strong> ${session.objetivo}</p>
          ${featuresHTML}
          ${problemesHTML}
          ${decisionsHTML}
          ${techHTML}
          ${deploysHTML}
          ${proximosHTML}
          ${session.notas_adicionales ? `<div class="session-notes"><h4>Notas Adicionales:</h4><pre>${session.notas_adicionales}</pre></div>` : ''}
        </div>
      `;
    }).join('');
    document.getElementById('fullSessions').innerHTML = sessionsHTML;
  } else {
    document.getElementById('fullSessions').innerHTML = '<p class="error">full/sessions.yaml not found</p>';
  }
}

// Helper para renderizar datos estructurados
function renderValue(value, level = 0) {
  if (value === null || value === undefined) return '<em>N/A</em>';

  if (typeof value === 'string') {
    return value.includes('\n') ? `<pre class="multiline">${value}</pre>` : value;
  }

  if (typeof value === 'number' || typeof value === 'boolean') {
    return `<code>${value}</code>`;
  }

  if (Array.isArray(value)) {
    if (value.length === 0) return '<em>Empty</em>';
    return '<ul>' + value.map(item => `<li>${renderValue(item, level + 1)}</li>`).join('') + '</ul>';
  }

  if (typeof value === 'object') {
    return '<dl class="nested-data">' +
      Object.keys(value).map(k => `
        <dt><strong>${k}:</strong></dt>
        <dd>${renderValue(value[k], level + 1)}</dd>
      `).join('') +
      '</dl>';
  }

  return String(value);
}

// Render Project Status
function renderProjectStatus() {
  if (!projectStatusData) {
    document.getElementById('projectStatusContent').innerHTML = '<p class="error">project-status.yaml not found</p>';
    return;
  }

  // Render as structured data
  const html = Object.keys(projectStatusData).map(key => {
    const value = projectStatusData[key];
    return `
      <div class="card">
        <h3>${key.replace(/_/g, ' ').toUpperCase()}</h3>
        ${renderValue(value)}
      </div>
    `;
  }).join('');

  document.getElementById('projectStatusContent').innerHTML = html;
}

// Render Stats
function renderStats() {
  if (!contextData || !contextData.notas_compilacion) {
    return;
  }

  const notes = contextData.notas_compilacion;

  document.getElementById('statADRsTotal').textContent = notes.adrs_totales || '-';
  document.getElementById('statADRsFiltered').textContent = notes.adrs_incluidas || '-';
  document.getElementById('statSessionsTotal').textContent = notes.sesiones_totales || '-';

  if (contextData.metadata) {
    document.getElementById('statLastCompiled').textContent = contextData.metadata.ultima_compilacion || '-';
  }

  // Rough token estimation
  const contextStr = JSON.stringify(contextData);
  const tokens = Math.round(contextStr.length / 4); // Rough estimate
  document.getElementById('statContextTokens').textContent = tokens.toLocaleString();

  // Compilation notes
  document.getElementById('compilationNotes').innerHTML = `
    <p><strong>Criterios de filtraje:</strong> ${notes.criterios_filtraje || 'N/A'}</p>
  `;
}

// Initialize on load
window.addEventListener('DOMContentLoaded', loadData);
