const state = {
  currentView: 'dashboard',
  imageData: null,
  imageName: '',
  cameraStream: null,
  latestResult: null,
  history: JSON.parse(localStorage.getItem('tilapiasize-history') || '[]')
};

const $ = (id) => document.getElementById(id);
const views = [...document.querySelectorAll('.view')];
const navItems = [...document.querySelectorAll('.nav-item')];
const jumpButtons = [...document.querySelectorAll('[data-jump]')];
const modeButtons = [...document.querySelectorAll('.mode-button')];

function setView(name) {
  state.currentView = name;
  views.forEach(v => v.classList.toggle('active', v.dataset.viewName === name));
  navItems.forEach(item => {
    const active = item.dataset.view === name;
    item.classList.toggle('active', active);
    if (active) item.setAttribute('aria-current', 'page'); else item.removeAttribute('aria-current');
  });
  const titles = { dashboard:'Dashboard', grade:'Grade Fish', history:'History', profile:'Profile' };
  $('pageTitle').textContent = titles[name] || 'TilapiaSize';
  $('sidebar').classList.remove('open');
  if (name === 'dashboard') refreshDashboard();
  if (name === 'history') renderHistory();
  window.scrollTo({ top: 0, behavior: 'smooth' });
}

navItems.forEach(item => item.addEventListener('click', () => setView(item.dataset.view)));
jumpButtons.forEach(btn => btn.addEventListener('click', () => setView(btn.dataset.jump)));
$('menuButton').addEventListener('click', () => $('sidebar').classList.toggle('open'));

document.addEventListener('click', (e) => {
  if (window.innerWidth <= 820 && $('sidebar').classList.contains('open') && !e.target.closest('#sidebar') && !e.target.closest('#menuButton')) {
    $('sidebar').classList.remove('open');
  }
});

function switchMode(mode) {
  modeButtons.forEach(btn => {
    const active = btn.dataset.mode === mode;
    btn.classList.toggle('active', active);
    btn.setAttribute('aria-selected', String(active));
  });
  $('uploadMode').classList.toggle('active', mode === 'upload');
  $('cameraMode').classList.toggle('active', mode === 'camera');
}
modeButtons.forEach(btn => btn.addEventListener('click', () => switchMode(btn.dataset.mode)));

const fishInput = $('fishInput');
const dropZone = $('dropZone');
fishInput.addEventListener('change', () => {
  const file = fishInput.files?.[0];
  if (file) handleFile(file);
});
['dragenter','dragover'].forEach(evt => dropZone.addEventListener(evt, e => { e.preventDefault(); dropZone.classList.add('dragover'); }));
['dragleave','drop'].forEach(evt => dropZone.addEventListener(evt, e => { e.preventDefault(); dropZone.classList.remove('dragover'); }));
dropZone.addEventListener('drop', e => {
  const file = e.dataTransfer.files?.[0];
  if (file) handleFile(file);
});

function handleFile(file) {
  const allowed = ['image/jpeg','image/png','image/webp'];
  if (!allowed.includes(file.type)) return toast('Please choose a JPG, PNG, or WEBP image.');
  if (file.size > 8 * 1024 * 1024) return toast('Image must be 8 MB or smaller.');
  const reader = new FileReader();
  reader.onload = () => {
    state.imageData = reader.result;
    state.imageName = file.name;
    showPreview(reader.result, file.name, `${(file.size / 1024 / 1024).toFixed(2)} MB · Ready to analyze`);
  };
  reader.readAsDataURL(file);
}

function showPreview(src, name, meta='Ready to analyze') {
  $('imagePreview').src = src;
  $('fileName').textContent = name;
  $('fileMeta').textContent = meta;
  $('previewCard').classList.remove('hidden');
  $('analyzeButton').disabled = false;
  resetAnalysisUI();
}

function clearImage() {
  state.imageData = null;
  state.imageName = '';
  state.latestResult = null;
  fishInput.value = '';
  $('previewCard').classList.add('hidden');
  $('analyzeButton').disabled = true;
  resetAnalysisUI();
}
$('removeImageButton').addEventListener('click', clearImage);

async function startCamera() {
  try {
    stopCamera();
    const stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: 'environment' }, audio: false });
    state.cameraStream = stream;
    $('cameraVideo').srcObject = stream;
    $('cameraVideo').style.display = 'block';
    $('cameraPlaceholder').classList.add('hidden');
    $('captureButton').disabled = false;
    toast('Camera started. Position the fish clearly in frame.');
  } catch (err) {
    toast('Camera access is unavailable or was not allowed.');
  }
}
function stopCamera() {
  if (state.cameraStream) {
    state.cameraStream.getTracks().forEach(t => t.stop());
    state.cameraStream = null;
  }
}
$('startCameraButton').addEventListener('click', startCamera);
$('captureButton').addEventListener('click', () => {
  const video = $('cameraVideo');
  const canvas = $('cameraCanvas');
  canvas.width = video.videoWidth || 1280;
  canvas.height = video.videoHeight || 720;
  canvas.getContext('2d').drawImage(video, 0, 0, canvas.width, canvas.height);
  const data = canvas.toDataURL('image/jpeg', .9);
  state.imageData = data;
  state.imageName = `camera-capture-${Date.now()}.jpg`;
  showPreview(data, 'Camera capture', 'Captured locally · Ready to analyze');
  stopCamera();
  $('cameraVideo').style.display = 'none';
  $('cameraPlaceholder').classList.remove('hidden');
  $('captureButton').disabled = true;
});

function resetAnalysisUI() {
  $('analysisIdle').classList.remove('hidden');
  $('analysisLoading').classList.add('hidden');
  $('analysisResult').classList.add('hidden');
}

function categoryFromLength(length) {
  // Demonstration thresholds only — replace with your validated project rules in production.
  if (length < 20) return { grade:'Small', category:'Juvenile / small', badge:'S' };
  if (length < 30) return { grade:'Medium', category:'Growing / medium', badge:'M' };
  return { grade:'Large', category:'Market size', badge:'L' };
}

async function analyzeImage() {
  if (!state.imageData) return;
  $('analysisIdle').classList.add('hidden');
  $('analysisResult').classList.add('hidden');
  $('analysisLoading').classList.remove('hidden');
  $('analyzeButton').disabled = true;

  const stages = [
    [24, 'Validating image'], [48, 'Preparing image for inference'], [72, 'Running size estimation'], [90, 'Applying grading rule'], [100, 'Preparing result']
  ];
  for (const [progress, label] of stages) {
    $('progressBar').style.width = `${progress}%`;
    $('progressLabel').textContent = label;
    await new Promise(r => setTimeout(r, 420));
  }

  // UI-only demonstration values. No ML inference occurs in this frontend.
  const seed = state.imageName.length + new Date().getMinutes();
  const length = 18 + (seed % 17) + ((seed * 7) % 10) / 10;
  const confidence = 88 + (seed % 9);
  const c = categoryFromLength(length);
  state.latestResult = {
    id: crypto.randomUUID ? crypto.randomUUID() : String(Date.now()),
    createdAt: new Date().toISOString(),
    imageData: state.imageData,
    imageName: state.imageName,
    length: Number(length.toFixed(1)),
    confidence,
    grade: c.grade,
    category: c.category
  };

  $('resultGrade').textContent = c.grade;
  $('resultBadge').textContent = c.badge;
  $('resultLength').textContent = `${state.latestResult.length.toFixed(1)} cm`;
  $('resultCategory').textContent = c.category;
  $('resultConfidence').textContent = `${confidence}%`;
  $('resultTime').textContent = new Date().toLocaleTimeString([], { hour:'2-digit', minute:'2-digit' });
  $('resultNote').textContent = `The detected fish falls in the ${c.grade.toLowerCase()} demonstration category based on the prototype threshold mapping.`;

  $('analysisLoading').classList.add('hidden');
  $('analysisResult').classList.remove('hidden');
  $('analyzeButton').disabled = false;
}
$('analyzeButton').addEventListener('click', analyzeImage);
$('analyzeAnotherButton').addEventListener('click', () => { clearImage(); window.scrollTo({ top: 0, behavior:'smooth' }); });

$('saveResultButton').addEventListener('click', () => {
  if (!state.latestResult) return;
  state.history.unshift(state.latestResult);
  state.history = state.history.slice(0, 30);
  localStorage.setItem('tilapiasize-history', JSON.stringify(state.history));
  refreshDashboard();
  toast('Result saved to demo history.');
  $('saveResultButton').textContent = 'Saved ✓';
  $('saveResultButton').disabled = true;
});

function refreshDashboard() {
  $('scanCount').textContent = state.history.length;
  $('largeCount').textContent = state.history.filter(r => r.grade === 'Large').length;
  $('latestGrade').textContent = state.history[0]?.grade || '—';
  const target = $('recentRecords');
  if (!state.history.length) {
    target.className = 'record-list empty-state compact';
    target.innerHTML = '<div class="empty-icon">◌</div><strong>No grading records yet</strong><p>Your saved results will appear here.</p>';
    return;
  }
  target.className = 'record-list';
  target.innerHTML = state.history.slice(0,4).map(r => `
    <div class="record-row">
      <img class="record-thumb" src="${r.imageData}" alt="Saved fish grading image" />
      <div><strong>${r.length.toFixed(1)} cm · ${r.category}</strong><small>${formatDate(r.createdAt)} · ${r.confidence}% confidence</small></div>
      <span class="record-grade">${r.grade}</span>
    </div>`).join('');
}

function renderHistory() {
  const query = $('historySearch').value.trim().toLowerCase();
  const filter = $('historyFilter').value;
  const filtered = state.history.filter(r => {
    const haystack = `${r.grade} ${r.category} ${formatDate(r.createdAt)} ${r.length}`.toLowerCase();
    return (filter === 'all' || r.grade === filter) && haystack.includes(query);
  });
  const body = $('historyTableBody');
  body.innerHTML = filtered.map(r => `
    <tr>
      <td><img class="table-thumb" src="${r.imageData}" alt="Fish grading thumbnail" /></td>
      <td>${formatDate(r.createdAt)}</td>
      <td>${r.length.toFixed(1)} cm</td>
      <td><span class="table-grade">${r.grade}</span></td>
      <td>${r.confidence}%</td>
      <td><button class="table-delete" data-delete-id="${r.id}">Delete</button></td>
    </tr>`).join('');
  $('historyEmpty').classList.toggle('hidden', state.history.length > 0);
  document.querySelector('.history-table-wrap').classList.toggle('hidden', filtered.length === 0);
  document.querySelectorAll('[data-delete-id]').forEach(btn => btn.addEventListener('click', () => deleteHistory(btn.dataset.deleteId)));
}
$('historySearch').addEventListener('input', renderHistory);
$('historyFilter').addEventListener('change', renderHistory);

function deleteHistory(id) {
  state.history = state.history.filter(r => r.id !== id);
  localStorage.setItem('tilapiasize-history', JSON.stringify(state.history));
  renderHistory();
  refreshDashboard();
  toast('Demo record deleted.');
}
$('clearHistoryButton').addEventListener('click', () => {
  if (!state.history.length) return toast('Demo history is already empty.');
  if (!confirm('Clear all locally saved demo grading records?')) return;
  state.history = [];
  localStorage.removeItem('tilapiasize-history');
  renderHistory();
  refreshDashboard();
  toast('Demo history cleared.');
});

function formatDate(iso) {
  return new Date(iso).toLocaleString([], { month:'short', day:'numeric', year:'numeric', hour:'2-digit', minute:'2-digit' });
}

let toastTimer;
function toast(message) {
  const el = $('toast');
  el.textContent = message;
  el.classList.add('show');
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => el.classList.remove('show'), 2600);
}

$('helpButton').addEventListener('click', () => $('helpModal').classList.remove('hidden'));
$('closeHelpButton').addEventListener('click', () => $('helpModal').classList.add('hidden'));
$('gotItButton').addEventListener('click', () => $('helpModal').classList.add('hidden'));
$('helpModal').addEventListener('click', e => { if (e.target === $('helpModal')) $('helpModal').classList.add('hidden'); });
$('saveProfileButton').addEventListener('click', () => toast('Prototype preferences saved locally for this session.'));

refreshDashboard();
renderHistory();
