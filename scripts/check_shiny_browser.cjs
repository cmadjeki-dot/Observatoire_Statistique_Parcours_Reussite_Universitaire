/* QA Chromium local : interactions reelles avec le serveur R Shiny. */
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const folder=path.join(__dirname,'../outputs/shiny-qa');fs.mkdirSync(folder,{recursive:true});
let ws;let counter=0;const pending=new Map();
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
async function call(method,params={}){return new Promise((resolve,reject)=>{const id=++counter;pending.set(id,{resolve,reject});ws.send(JSON.stringify({id,method,params}));});}
async function evaluate(expression){const result=await call('Runtime.evaluate',{expression,returnByValue:true,awaitPromise:true});if(result.exceptionDetails)throw Error(result.exceptionDetails.text);return result.result.value;}
async function waitFor(expression){for(let i=0;i<100;i++){if(await evaluate(expression))return;await sleep(150);}throw Error('Attente navigateur depassee : '+expression);}
async function change(id,value){await evaluate(`document.getElementById(${JSON.stringify(id)}).value=${JSON.stringify(value)};document.getElementById(${JSON.stringify(id)}).dispatchEvent(new Event('change',{bubbles:true}));`);}
async function screenshot(name){const r=await call('Page.captureScreenshot',{format:'png',captureBeyondViewport:false});fs.writeFileSync(path.join(folder,name),Buffer.from(r.data,'base64'));}
(async()=>{
  const pages=await (await fetch('http://127.0.0.1:9226/json/list')).json();
  const page=pages.find(x=>x.type==='page');assert.ok(page);
  ws=new WebSocket(page.webSocketDebuggerUrl);
  await new Promise((resolve,reject)=>{ws.addEventListener('open',resolve,{once:true});ws.addEventListener('error',reject,{once:true});});
  ws.addEventListener('message',event=>{const r=JSON.parse(event.data);if(pending.has(r.id)){const p=pending.get(r.id);pending.delete(r.id);if(r.error)p.reject(Error(r.error.message));else p.resolve(r.result);}});
  await call('Page.enable');await call('Runtime.enable');
  await call('Emulation.setDeviceMetricsOverride',{width:1450,height:1200,deviceScaleFactor:1,mobile:false});
  await call('Page.navigate',{url:'http://127.0.0.1:3839'});
  await waitFor(`document.querySelector('#kpis')?.innerText.includes('73,2') && document.querySelector('#evolution_plot img')?.naturalWidth>0`);
  assert.ok(await evaluate(`document.querySelector('#kpis').innerText.includes('71,4') && document.querySelector('#kpis').innerText.includes('Non observable')`));
  await screenshot('shiny-desktop.png');
  if(process.argv.includes('--capture-only')){
    await call('Emulation.setDeviceMetricsOverride',{width:390,height:844,deviceScaleFactor:1,mobile:true});
    await sleep(700);assert.ok(await evaluate(`document.documentElement.scrollWidth<=innerWidth+2`));
    await screenshot('shiny-mobile.png');console.log('Captures finales et largeur mobile verifiees.');
    await call('Browser.close');return;
  }
  await change('formation','F01');await waitFor(`document.querySelector('#kpis').innerText.replace(/\\s/g,'').includes('2752')`);
  await change('year','2024-2025');await change('formation','all');
  await waitFor(`document.querySelector('#kpis').innerText.includes('Masqué')`);
  await evaluate(`document.querySelector('#view input[value="journeys"]').click()`);
  await waitFor(`document.querySelector('#journey_kpis').getBoundingClientRect().width>0 && document.querySelector('#journey_kpis').innerText.includes('65,9')`);
  await evaluate(`document.getElementById('reset').click()`);
  await waitFor(`document.getElementById('year').value==='2025-2026' && document.getElementById('formation').value==='all' && document.querySelector('#journey_kpis').innerText.includes('Non observable')`);
  await evaluate(`document.querySelector('#view input[value="overview"]').click()`);
  await evaluate(`document.querySelector('#metric input[value="enrolment"]').click()`);
  await waitFor(`document.querySelector('#chart_title').innerText.includes('effectifs')`);
  await evaluate(`document.getElementById('open_methods').click()`);
  await waitFor(`document.querySelector('#view input[value="methods"]').checked`);
  assert.equal(await evaluate(`document.querySelectorAll('.method summary').length`),8);
  await evaluate(`document.querySelector('.method summary').click()`);
  assert.ok(await evaluate(`document.querySelector('.method').open`));
  await evaluate(`document.querySelector('#view input[value="overview"]').click()`);
  await call('Emulation.setDeviceMetricsOverride',{width:390,height:844,deviceScaleFactor:1,mobile:true});
  await sleep(700);assert.ok(await evaluate(`document.documentElement.scrollWidth<=innerWidth+2`));
  await screenshot('shiny-mobile.png');
  const proof={statut:'valide',controles:['cartes initiales','filtre formation','filtre annee','masquage','navigation parcours','censure','reinitialisation','graphique effectifs','navigation methodes','huit fiches','ouverture fiche','largeur mobile'],url:'http://127.0.0.1:3839'};
  fs.writeFileSync(path.join(folder,'recette-navigateur.json'),JSON.stringify(proof,null,2));console.log(JSON.stringify(proof));
})().catch(error=>{console.error(error);process.exitCode=1;}).finally(()=>{if(ws)ws.close();});
