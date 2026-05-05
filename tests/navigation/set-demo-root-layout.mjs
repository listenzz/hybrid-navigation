#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const layouts = new Set(['stack-drawer-tabs', 'drawer-stack-tabs']);
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const projectRoot = path.resolve(__dirname, '../..');
const indexPath = path.join(projectRoot, 'src/index.ts');
const source = fs.readFileSync(indexPath, 'utf8');
const pattern = /const demoRootLayout: DemoRootLayout = '([^']+)';/;
const match = source.match(pattern);

if (!match) {
	console.error('Unable to find demoRootLayout in src/index.ts.');
	process.exit(1);
}

const current = match[1];
const command = process.argv[2];

if (command === '--get') {
	console.log(current);
	process.exit(0);
}

if (!layouts.has(command)) {
	console.error(`Usage: node ${path.relative(projectRoot, __filename)} <${[...layouts].join('|')}>`);
	process.exit(1);
}

if (command === current) {
	console.log(`demoRootLayout already ${command}`);
	process.exit(0);
}

fs.writeFileSync(indexPath, source.replace(pattern, `const demoRootLayout: DemoRootLayout = '${command}';`));
console.log(`demoRootLayout: ${current} -> ${command}`);
