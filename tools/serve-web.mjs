import http from 'node:http';
import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '..');
const webRoot = path.join(root, 'app/build/web');

const types = {
  '.html': 'text/html',
  '.js': 'text/javascript',
  '.json': 'application/json',
  '.wasm': 'application/wasm',
  '.png': 'image/png',
  '.woff2': 'font/woff2',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf'
};

const server = http.createServer(async (req, res) => {
  const pathname = decodeURIComponent(new URL(req.url, 'http://localhost').pathname);
  const filename = path.resolve(webRoot, '.' + pathname);
  if (filename !== webRoot && !filename.startsWith(webRoot + path.sep)) {
    res.writeHead(403).end();
    return;
  }
  try {
    const target = filename === webRoot ? path.join(webRoot, 'index.html') : filename;
    res.setHeader('Content-Type', types[path.extname(target)] || 'application/octet-stream');
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.end(await readFile(target));
  } catch {
    res.writeHead(404).end();
  }
});

server.listen(8080, '0.0.0.0', () => {
  console.log('GymLevel Web Server running at http://localhost:8080');
});
