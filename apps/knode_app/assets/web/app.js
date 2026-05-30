const API = '';
document.querySelectorAll('.nav-item').forEach(el => {
  el.addEventListener('click', e => {
    e.preventDefault();
    document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
    document.querySelectorAll('.view').forEach(v => v.classList.remove('active'));
    el.classList.add('active');
    document.getElementById('view-' + el.dataset.view).classList.add('active');
  });
});

async function loadDocs() {
  try {
    const resp = await fetch(API + '/api/docs');
    const data = await resp.json();
    const list = document.getElementById('doc-list');
    list.innerHTML = (data.docs || []).map(d => '<div class="card"><h3>' + d.title + '</h3><p>更新: ' + d.updatedAt + '</p></div>').join('') || '<div class="card"><p>暂无文档</p></div>';
  } catch(e) { document.getElementById('doc-list').innerHTML = '<div class="card"><p>加载失败</p></div>'; }
}

async function sendAiMessage() {
  const input = document.getElementById('ai-input');
  const msg = input.value.trim();
  if (!msg) return;
  input.value = '';
  const chat = document.getElementById('chat-messages');
  chat.innerHTML += '<div class="chat-msg user">' + msg + '</div>';
  try {
    const resp = await fetch(API + '/api/ai/ask', {method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify({query:msg})});
    const data = await resp.json();
    chat.innerHTML += '<div class="chat-msg assistant">' + (data.answer || data.error || '无回答') + '</div>';
  } catch(e) { chat.innerHTML += '<div class="chat-msg assistant">请求失败</div>'; }
  chat.scrollTop = chat.scrollHeight;
}

document.getElementById('ai-send').addEventListener('click', sendAiMessage);
document.getElementById('ai-input').addEventListener('keydown', e => { if (e.key === 'Enter') sendAiMessage(); });
loadDocs();