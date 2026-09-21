#!/usr/bin/env node
/**
 * What CI gates on.
 *
 * `claude plugin validate` is the authority on manifest shape, but it needs
 * the Claude CLI installed and is not guaranteed to run unauthenticated, so it
 * is advisory in the workflow. These checks need nothing but Node, and they
 * cover the failures that actually reach users: a marketplace whose entry
 * points at a directory that is not there, and a version bump applied in one
 * file and not the other -- which produces a plugin that never updates and
 * gives no error while not updating.
 */
import { existsSync, readFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const repo = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const fail = [];
const read = (rel) => {
  const p = join(repo, rel);
  if (!existsSync(p)) { fail.push(`missing ${rel}`); return null; }
  try { return JSON.parse(readFileSync(p, 'utf8')); }
  catch (e) { fail.push(`${rel} is not valid JSON: ${e.message}`); return null; }
};

const market = read('.claude-plugin/marketplace.json');
if (market) {
  if (!market.name) fail.push('marketplace.json has no name');
  if (!market.owner?.name) fail.push('marketplace.json has no owner.name');
  if (!Array.isArray(market.plugins) || market.plugins.length === 0) {
    fail.push('marketplace.json lists no plugins');
  }

  for (const entry of market.plugins ?? []) {
    if (!entry.name) { fail.push('a plugin entry has no name'); continue; }
    if (typeof entry.source !== 'string') {
      // Non-local sources (npm, github, archive) are resolved at install time;
      // nothing here can check them.
      continue;
    }
    const dir = join(repo, entry.source);
    if (!existsSync(dir)) {
      fail.push(`${entry.name}: source ${entry.source} does not exist`);
      continue;
    }
    const manifestRel = join(entry.source, '.claude-plugin/plugin.json');
    const manifest = read(manifestRel);
    if (!manifest) continue;

    if (manifest.name !== entry.name) {
      fail.push(`${entry.name}: plugin.json says name ${manifest.name}`);
    }
    if (entry.version && manifest.version && entry.version !== manifest.version) {
      fail.push(
        `${entry.name}: marketplace.json says ${entry.version}, ` +
        `plugin.json says ${manifest.version}. Bump both, or drop one.`,
      );
    }
    if (entry.license && manifest.license && entry.license !== manifest.license) {
      fail.push(`${entry.name}: licence disagrees (${entry.license} vs ${manifest.license})`);
    }

    for (const required of ['.mcp.json', 'README.md', 'LICENSE']) {
      if (!existsSync(join(dir, required))) fail.push(`${entry.name}: missing ${required}`);
    }

    const mcp = read(join(entry.source, '.mcp.json'));
    if (mcp && Object.keys(mcp.mcpServers ?? {}).length === 0) {
      fail.push(`${entry.name}: .mcp.json declares no servers`);
    }

    // A plugin that ships a skills/ directory but no SKILL.md installs and
    // does nothing.
    const skills = join(dir, 'skills');
    if (existsSync(skills)) {
      const { readdirSync } = await import('node:fs');
      for (const name of readdirSync(skills)) {
        if (!existsSync(join(skills, name, 'SKILL.md'))) {
          fail.push(`${entry.name}: skills/${name} has no SKILL.md`);
        }
      }
    }
  }
}

if (fail.length > 0) {
  console.error(fail.map((f) => `  ✘ ${f}`).join('\n'));
  process.exit(1);
}
console.log(`ok: ${market.name} — ${market.plugins.map((p) => `${p.name}@${p.version ?? 'unpinned'}`).join(', ')}`);
