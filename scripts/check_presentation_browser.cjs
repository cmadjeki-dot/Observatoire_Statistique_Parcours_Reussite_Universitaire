const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const out=path.join(__dirname,'../outputs/site-presentation-qa');let ws,next=0;const pending=new Map(),sleep=ms=>new Promise(r=>setTimeout(r,ms));
function call(method,params={}){return new Promise((resolve,reject)=>{const id=++next;pending.set(id,{resolve,reject});ws.send(JSON.stringify({id,method,params}));});}
async function evaluate(expression){const r=await call('Runtime.evaluate',{expression,returnByValue:true,awaitPromise:true});if(r.exceptionDetails)throw Error(r.exceptionDetails.text);return r.result.value;}
async function waitFor(expression){for(let i=0;i<120;i++){if(await evaluate(expression))return;await sleep(150);}throw Error('Attente depassee : '+expression);}
async function screenshot(name){const r=await call('Page.captureScreenshot',{format:'png',captureBeyondViewport:false});fs.writeFileSync(path.join(out,name),Buffer.from(r.data,'base64'));}
async function navigate(url){await call('Page.navigate',{url:'http://127.0.0.1:8047/'+url});}
(async()=>{
  const pages=await(await fetch('http://127.0.0.1:9230/json/list')).json();
  ws=new WebSocket(pages.find(p=>p.type==='page').webSocketDebuggerUrl);
  await new Promise((r,j)=>{ws.addEventListener('open',r,{once:true});ws.addEventListener('error',j,{once:true});});
  ws.addEventListener('message',e=>{const r=JSON.parse(e.data);if(pending.has(r.id)){const p=pending.get(r.id);pending.delete(r.id);r.error?p.reject(Error(r.error.message)):p.resolve(r.result);}});
  await call('Page.enable');await call('Runtime.enable');
  await call('Emulation.setDeviceMetricsOverride',{width:1450,height:1100,deviceScaleFactor:1,mobile:false});
  await navigate('index.html');await waitFor(`document.querySelectorAll('#report-toc li').length===13 && document.querySelector('.hero-visual img')?.naturalWidth>0`);
  await waitFor(`document.querySelector('iframe')?.contentDocument?.querySelector('#kpis')?.innerText.includes('73,2')`);
  await screenshot('accueil-bureau.png');
  await evaluate(`document.querySelector('#tab-shiny').click()`);
  assert.ok(await evaluate(`!document.querySelector('#panel-shiny').hidden && document.querySelector('#panel-web').hidden`));
  await evaluate(`document.querySelector('#tab-powerbi').click()`);
  assert.ok(await evaluate(`!document.querySelector('#panel-powerbi').hidden && document.querySelector('#panel-shiny').hidden`));
  assert.ok(await evaluate(`document.querySelector('#panel-powerbi a[download]').href.endsWith('.zip')`));
  await evaluate(`document.querySelector('#tab-web').click()`);
  const anchors=await evaluate(`[...document.querySelectorAll('#report-toc a')].map(a=>new URL(a.href).hash)`);
  assert.equal(anchors.length,13);
  await navigate('rapport_final.html'+anchors[0]);await waitFor(`document.querySelector('#quarto-document-content') || document.querySelector('main')`);
  await waitFor(`document.getElementById(decodeURIComponent(location.hash.slice(1)))!==null`);
  assert.equal(await evaluate(`document.querySelectorAll('section.level1').length`),13);
  assert.ok(await evaluate(`document.body.innerText.includes('13 Reproductibilité et accès aux livrables')`));
  await screenshot('rapport-final.png');
  await navigate('index.html');await waitFor(`document.querySelectorAll('#report-toc li').length===13`);
  await call('Emulation.setDeviceMetricsOverride',{width:390,height:844,deviceScaleFactor:1,mobile:true});await sleep(500);
  assert.ok(await evaluate(`document.documentElement.scrollWidth<=innerWidth+2`));
  await evaluate(`document.querySelector('.menu-toggle').click()`);
  assert.ok(await evaluate(`document.querySelector('.menu-toggle').getAttribute('aria-expanded')==='true'`));
  await evaluate(`document.querySelector('#main-nav a').click()`);
  assert.ok(await evaluate(`document.querySelector('.menu-toggle').getAttribute('aria-expanded')==='false'`));
  await evaluate(`window.scrollTo(0,0)`);await screenshot('accueil-mobile.png');
  const checks={statut:'valide',controles:['accueil bureau','tableau web integre','onglets Shiny et Power BI','telechargement Power BI','13 liens de sommaire','13 sections du rapport','ancre du rapport','menu mobile','absence de debordement mobile'],rapport_chapitres:13};
  fs.writeFileSync(path.join(out,'recette-navigateur.json'),JSON.stringify(checks,null,2));console.log(JSON.stringify(checks));
  await call('Browser.close');
})().catch(e=>{console.error(e);process.exitCode=1;}).finally(()=>{if(ws)ws.close();});
