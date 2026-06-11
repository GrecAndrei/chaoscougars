#!/usr/bin/env node
/**
 * Batch converter: splits effects_generated.lua into chunks,
 * feeds each to M3 for multiplayer conversion, collects output.
 *
 * Usage: node batch_convert.mjs [--batch N] [--start N]
 *   --batch N: batch size (default 50 functions per call)
 *   --start N: start from batch N (for resuming)
 */

import { readFileSync, writeFileSync, mkdirSync } from 'fs';
import { execSync } from 'child_process';
import { argv } from 'process';

const TOOLS_DIR = new URL('.', import.meta.url).pathname.replace(/^\/([A-Z]:)/, '$1');
const RESOURCE_DIR = TOOLS_DIR.replace(/tools\/$/, 'resource/');
const OUTPUT_DIR = TOOLS_DIR + 'm3_output/';

try { mkdirSync(OUTPUT_DIR, { recursive: true }); } catch {}

const args = argv.slice(2);
let BATCH_SIZE = 50;
let START_BATCH = 0;

for (let i = 0; i < args.length; i++) {
  if (args[i] === '--batch') BATCH_SIZE = parseInt(args[++i], 10);
  if (args[i] === '--start') START_BATCH = parseInt(args[++i], 10);
}

// Parse generated effects into individual functions
const source = readFileSync(RESOURCE_DIR + 'client/effects_generated.lua', 'utf-8');
const lines = source.split('\n');

// Extract function blocks
const functions = [];
let current = null;
let depth = 0;

for (let i = 0; i < lines.length; i++) {
  const line = lines[i];

  if (line.match(/^function FX_/)) {
    current = { name: line.match(/^function (FX_\w+)/)[1], start: i, lines: [line] };
    depth = 1;
  } else if (current) {
    current.lines.push(line);
    // Track end blocks (simplified: count function/if/while/for -> end)
    const opens = (line.match(/\b(function|if|while|for|do)\b/g) || []).length;
    const closes = (line.match(/\bend\b/g) || []).length;
    depth += opens - closes;
    if (depth <= 0) {
      functions.push(current);
      current = null;
      depth = 0;
    }
  }
}

console.log(`Found ${functions.length} functions`);

// Also extract the helper section (before first function)
const firstFuncLine = functions[0]?.start || 0;
const helperSection = lines.slice(0, firstFuncLine).join('\n');

// Split into batches
const batches = [];
for (let i = 0; i < functions.length; i += BATCH_SIZE) {
  batches.push(functions.slice(i, i + BATCH_SIZE));
}

console.log(`Split into ${batches.length} batches of ~${BATCH_SIZE}`);

// Process each batch
for (let batchIdx = START_BATCH; batchIdx < batches.length; batchIdx++) {
  const batch = batches[batchIdx];
  const batchCode = batch.map(f => f.lines.join('\n')).join('\n\n');

  const prompt = `Convert these ${batch.length} FiveM Lua chaos effects to multiplayer-safe versions.\nClassify each with sync_mode and apply ownership guards where needed.\nKeep function names exactly as they are.\n\n${batchCode}`;

  const promptFile = OUTPUT_DIR + `batch_${batchIdx}_prompt.txt`;
  const outputFile = OUTPUT_DIR + `batch_${batchIdx}_output.lua`;

  writeFileSync(promptFile, prompt);

  console.log(`\n=== Batch ${batchIdx + 1}/${batches.length} (${batch.length} functions: ${batch[0].name} ... ${batch[batch.length-1].name}) ===`);

  try {
    const result = execSync(
      `node "${TOOLS_DIR}minimax.mjs" --file "${promptFile}" --system "${TOOLS_DIR}m3_system.txt" --max-tokens 32000 --temperature 0.3`,
      { encoding: 'utf-8', timeout: 300000, stdio: ['pipe', 'pipe', 'pipe'] }
    );
    writeFileSync(outputFile, result);
    console.log(`  -> Wrote ${outputFile} (${result.split('\n').length} lines)`);
  } catch (err) {
    console.error(`  !! Batch ${batchIdx} failed: ${err.message?.slice(0, 200)}`);
    writeFileSync(outputFile, `-- FAILED: ${err.message?.slice(0, 200)}\n`);
  }
}

console.log('\n=== Done! Concatenate outputs with: ===');
console.log(`cat ${OUTPUT_DIR}batch_*_output.lua > ${RESOURCE_DIR}client/effects_generated.lua`);
