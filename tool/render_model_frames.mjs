// Renders a glTF animation to a numbered PNG sequence.
//
// Flutter has no glTF renderer, and every runtime option costs a WebView. So
// the bird is rendered once, here, and the app plays back frames instead.
//
// Frames are stepped by setting the animation mixer to an exact time rather
// than capturing in real time, so the loop is deterministic and seamless: the
// last frame lands just before the first, never on top of it.
//
//   node render_model_frames.mjs <model.glb> <outDir> [frames] [size] [clip]
//
// A model can carry several clips — the falcon ships Fly_Loop, Idle and
// Idle_Waggle_7s in one file — so name the one you want. Omit it and the tool
// lists what the model holds and stops, rather than guessing at the first.
//
// Name two as "A|B" to play B right after A — for a burst the model already
// carries, like the falcon's waggle, which starts and ends where its idle
// does. Name them "A>B" to bake the blend between them instead. The falcon has no clip for
// folding its wings, so the fold is made by letting the mixer cross-fade the
// skeleton from flight into the perched pose — bones interpolating, not images
// dissolving.

import { createServer } from 'node:http';
import { createReadStream } from 'node:fs';
import { mkdir, writeFile, stat } from 'node:fs/promises';
import { extname, join, resolve } from 'node:path';
import puppeteer from 'puppeteer';

const MODEL = resolve(process.argv[2]);
const OUT_DIR = resolve(process.argv[3]);
// "30" for a plain loop; "30+14" to follow the loop with a blend into the
// second clip. Both halves are rendered in one pass so they share a crop —
// cropped apart, the bird would jump at the seam between them.
const [LOOP_FRAMES, BLEND_FRAMES] = (process.argv[4] ?? '30')
  .split('+')
  .map(Number);
const FRAMES = LOOP_FRAMES + (BLEND_FRAMES || 0);
const SIZE = Number(process.argv[5] ?? 320);
const CLIP = process.argv[6] ?? null;
// Where the camera stands, in degrees: yaw around the bird, pitch above it.
// A flying pose reads from above; a perched one wants closer to eye level.
const [YAW, PITCH] = (process.argv[7] ?? '30,9').split(',').map(Number);
// Rendered larger than it ships, so the crop has detail to resample from.
const RENDER_SIZE = SIZE * 2;

const TYPES = {
  '.js': 'text/javascript',
  '.html': 'text/html',
  '.glb': 'model/gltf-binary',
};

const PAGE = `<!doctype html>
<body style="margin:0">
<script type="importmap">
{"imports":{
  "three":"/node_modules/three/build/three.module.js",
  "three/addons/":"/node_modules/three/examples/jsm/"
}}
</script>
<script type="module">
import * as THREE from 'three';
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';
window.THREE = THREE;
window.GLTFLoader = GLTFLoader;
window.ready = true;
</script>
</body>`;

// Serving over HTTP rather than inlining the modules: three's build imports a
// sibling file relative to itself, which a blob URL cannot resolve.
const server = createServer(async (request, response) => {
  const path = decodeURIComponent(new URL(request.url, 'http://x').pathname);

  if (path === '/') {
    response.writeHead(200, { 'content-type': 'text/html' });
    return response.end(PAGE);
  }

  const file = path === '/model.glb' ? MODEL : join(process.cwd(), path);
  try {
    await stat(file);
  } catch {
    response.writeHead(404);
    return response.end();
  }
  response.writeHead(200, {
    'content-type': TYPES[extname(file)] ?? 'application/octet-stream',
  });
  createReadStream(file).pipe(response);
});

await new Promise((done) => server.listen(0, '127.0.0.1', done));
const origin = `http://127.0.0.1:${server.address().port}`;

const browser = await puppeteer.launch({
  headless: 'shell',
  args: [
    '--use-gl=angle',
    '--use-angle=swiftshader',
    '--enable-unsafe-swiftshader',
  ],
});
const page = await browser.newPage();
await page.setViewport({ width: RENDER_SIZE, height: RENDER_SIZE });
page.on('pageerror', (error) => console.log('  page error:', error.message));

await page.goto(origin, { waitUntil: 'networkidle0' });
await page.waitForFunction('window.ready === true', { timeout: 30000 });

const frames = await page.evaluate(
  async (loopFrames, blendFrames, size, outSize, clipName, yaw, pitch) => {
    const { THREE, GLTFLoader } = window;

    const renderer = new THREE.WebGLRenderer({
      antialias: true,
      alpha: true,
      preserveDrawingBuffer: true,
    });
    renderer.setSize(size, size);
    renderer.setClearColor(0x000000, 0);
    document.body.appendChild(renderer.domElement);

    const scene = new THREE.Scene();
    scene.add(new THREE.AmbientLight(0xffffff, 2.2));
    const key = new THREE.DirectionalLight(0xffffff, 2.6);
    key.position.set(2, 3, 4);
    scene.add(key);
    const rim = new THREE.DirectionalLight(0xffffff, 1.2);
    rim.position.set(-3, 1, -2);
    scene.add(rim);

    const gltf = await new GLTFLoader().loadAsync('/model.glb');
    const model = gltf.scene;
    scene.add(model);

    // Frame the bird: centre it on the origin, then pull the camera back to
    // the radius of its bounding sphere so any model fills the tile alike.
    const box = new THREE.Box3().setFromObject(model);
    model.position.sub(box.getCenter(new THREE.Vector3()));
    const radius = box.getBoundingSphere(new THREE.Sphere()).radius;

    const camera = new THREE.PerspectiveCamera(35, 1, 0.1, 1000);
    // Deliberately loose: the wings swing past the rest pose the bounds were
    // measured from, and the crop below tightens what this leaves slack.
    const distance = (radius / Math.sin((35 / 2) * (Math.PI / 180))) * 1.45;
    const yawRad = (yaw * Math.PI) / 180;
    const pitchRad = (pitch * Math.PI) / 180;
    camera.position.set(
      distance * Math.cos(pitchRad) * Math.sin(yawRad),
      distance * Math.sin(pitchRad),
      distance * Math.cos(pitchRad) * Math.cos(yawRad),
    );
    camera.lookAt(0, 0, 0);

    const available = gltf.animations.map((a) => a.name);
    if (available.length === 0) {
      throw new Error('the model carries no animation');
    }
    const find = (name) => {
      const found = gltf.animations.find((a) => a.name === name);
      if (!found) {
        throw new Error(`name one of these clips: ${available.join(', ')}`);
      }
      return found;
    };

    const blended = (clipName ?? '').includes('>');
    const [fromName, toName] = (clipName ?? '').split(blended ? '>' : '|');
    const clip = find(fromName);
    const tail = toName ? find(toName) : null;
    const blendTo = blended ? tail : null;
    const mixer = new THREE.AnimationMixer(model);
    const action = mixer.clipAction(clip);
    action.play();

    // A blend has to be advanced, not seeked: cross-fading is a running state
    // the mixer keeps, and seeking would throw it away every frame.
    const blendSeconds = blendTo ? clip.duration : 0;

    const source = document.createElement('canvas');
    source.width = source.height = size;
    const sourceCtx = source.getContext('2d', { willReadFrequently: true });

    const rendered = [];
    for (let frame = 0; frame < loopFrames; frame++) {
      // Stops one step short of the full clip, so the loop does not show the
      // same frame twice when it wraps.
      mixer.setTime((frame / loopFrames) * clip.duration);
      renderer.render(scene, camera);
      sourceCtx.clearRect(0, 0, size, size);
      sourceCtx.drawImage(renderer.domElement, 0, 0);
      rendered.push(sourceCtx.getImageData(0, 0, size, size));
    }

    if (blendTo) {
      // A blend has to be advanced, not seeked: cross-fading is a running
      // state the mixer keeps, and seeking would throw it away every frame.
      const target = mixer.clipAction(blendTo);
      target.play();
      action.crossFadeTo(target, blendSeconds, false);

      for (let frame = 0; frame < blendFrames; frame++) {
        mixer.update(blendSeconds / (blendFrames - 1));
        renderer.render(scene, camera);
        sourceCtx.clearRect(0, 0, size, size);
        sourceCtx.drawImage(renderer.domElement, 0, 0);
        rendered.push(sourceCtx.getImageData(0, 0, size, size));
      }
    } else if (tail) {
      // Played whole rather than blended: this one already begins and ends on
      // the pose the loop before it rests in.
      action.stop();
      const burst = mixer.clipAction(tail);
      burst.play();
      for (let frame = 0; frame < blendFrames; frame++) {
        mixer.setTime((frame / blendFrames) * tail.duration);
        renderer.render(scene, camera);
        sourceCtx.clearRect(0, 0, size, size);
        sourceCtx.drawImage(renderer.domElement, 0, 0);
        rendered.push(sourceCtx.getImageData(0, 0, size, size));
      }
    }

    // Fitting a camera to a skinned mesh guesses at where the wings will
    // reach; the alpha channel knows. Crop every frame to the same box — the
    // union of what the bird actually touched — so the framing is tight and
    // the bird does not swim inside the tile between frames.
    let minX = size;
    let minY = size;
    let maxX = -1;
    let maxY = -1;
    for (const image of rendered) {
      for (let y = 0; y < size; y++) {
        for (let x = 0; x < size; x++) {
          if (image.data[(y * size + x) * 4 + 3] <= 8) continue;
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
        }
      }
    }
    if (maxX < 0) throw new Error('every frame came out empty');

    const span = Math.max(maxX - minX, maxY - minY);
    const side = span * 1.04;
    const left = (minX + maxX) / 2 - side / 2;
    const top = (minY + maxY) / 2 - side / 2;

    const out = document.createElement('canvas');
    out.width = out.height = outSize;
    const outCtx = out.getContext('2d');

    const shots = [];
    for (const image of rendered) {
      sourceCtx.putImageData(image, 0, 0);
      outCtx.clearRect(0, 0, outSize, outSize);
      outCtx.drawImage(source, left, top, side, side, 0, 0, outSize, outSize);
      shots.push(out.toDataURL('image/png'));
    }

    return { shots, name: clip.name, duration: clip.duration };
  },
  LOOP_FRAMES,
  BLEND_FRAMES ?? 0,
  RENDER_SIZE,
  SIZE,
  CLIP,
  YAW,
  PITCH,
);

await mkdir(OUT_DIR, { recursive: true });
for (const [index, dataUrl] of frames.shots.entries()) {
  await writeFile(
    join(OUT_DIR, `${String(index).padStart(2, '0')}.png`),
    Buffer.from(dataUrl.split(',')[1], 'base64'),
  );
}

console.log(
  `rendered ${frames.shots.length} frames of "${frames.name}" ` +
    `(${frames.duration.toFixed(2)}s) at ${SIZE}px into ${OUT_DIR}`,
);

await browser.close();
server.close();
