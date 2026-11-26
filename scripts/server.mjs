import { createServer } from 'node:http';
import { readFile } from 'node:fs/promises';

const port = Number(process.env.PORT || 3000);
const page = await readFile(new URL('../dist/index.html', import.meta.url));

createServer((request, response) => {
  if (request.url !== '/' && request.url !== '/index.html') {
    response.writeHead(404);
    response.end('Not found');
    return;
  }

  response.writeHead(200, {
    'content-type': 'text/html; charset=utf-8',
    'content-length': page.length,
  });
  response.end(request.method === 'HEAD' ? undefined : page);
}).listen(port, '0.0.0.0', () => {
  console.log(`X Versions listening on 0.0.0.0:${port}`);
});
