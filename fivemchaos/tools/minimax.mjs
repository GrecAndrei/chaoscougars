#!/usr/bin/env node
/**
 * Minimax M3 harness via TokenRouter API.
 * Usage:
 *   node minimax.mjs "prompt text"
 *   node minimax.mjs --file prompt.txt
 *   node minimax.mjs --file prompt.txt --system system.txt
 *   echo "prompt" | node minimax.mjs --stdin
 *
 * Env: TOKENROUTER_API_KEY
 * Outputs the assistant response to stdout. Reasoning/thinking to stderr.
 */

import { readFileSync } from 'fs';
import { argv, env, stdin, stderr, stdout } from 'process';

const API_URL = 'https://api.tokenrouter.com/v1/chat/completions';
const MODEL = 'MiniMax-M3';
const API_KEY = env.TOKENROUTER_API_KEY;

if (!API_KEY) {
  stderr.write('ERROR: TOKENROUTER_API_KEY not set\n');
  process.exit(1);
}

async function readStdin() {
  const chunks = [];
  for await (const chunk of stdin) chunks.push(chunk);
  return Buffer.concat(chunks).toString('utf-8');
}

function parseArgs() {
  const args = argv.slice(2);
  const opts = { prompt: null, system: null, maxTokens: 16384, temperature: 0.6 };

  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--file' && args[i + 1]) {
      opts.prompt = readFileSync(args[++i], 'utf-8');
    } else if (args[i] === '--system' && args[i + 1]) {
      opts.system = readFileSync(args[++i], 'utf-8');
    } else if (args[i] === '--stdin') {
      opts.prompt = '__STDIN__';
    } else if (args[i] === '--max-tokens' && args[i + 1]) {
      opts.maxTokens = parseInt(args[++i], 10);
    } else if (args[i] === '--temperature' && args[i + 1]) {
      opts.temperature = parseFloat(args[++i]);
    } else if (!args[i].startsWith('--')) {
      opts.prompt = args[i];
    }
  }
  return opts;
}

async function callAPI(prompt, system, maxTokens, temperature) {
  const messages = [];
  if (system) messages.push({ role: 'system', content: system });
  messages.push({ role: 'user', content: prompt });

  const body = {
    model: MODEL,
    messages,
    max_tokens: maxTokens,
    temperature,
    stream: true,
  };

  const res = await fetch(API_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${API_KEY}`,
    },
    body: JSON.stringify(body),
  });

  if (!res.ok) {
    const text = await res.text();
    throw new Error(`API error ${res.status}: ${text}`);
  }

  const reader = res.body.getReader();
  const decoder = new TextDecoder();
  let buffer = '';
  let fullContent = '';
  let fullReasoning = '';

  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    buffer += decoder.decode(value, { stream: true });

    const lines = buffer.split('\n');
    buffer = lines.pop();

    for (const line of lines) {
      if (!line.startsWith('data: ')) continue;
      const data = line.slice(6).trim();
      if (data === '[DONE]') continue;

      try {
        const json = JSON.parse(data);
        const delta = json.choices?.[0]?.delta;
        if (!delta) continue;

        if (delta.reasoning_content) {
          fullReasoning += delta.reasoning_content;
          stderr.write(delta.reasoning_content);
        }
        if (delta.content) {
          fullContent += delta.content;
        }
      } catch {}
    }
  }

  // Flush remaining buffer
  if (buffer.startsWith('data: ') && buffer.slice(6).trim() !== '[DONE]') {
    try {
      const json = JSON.parse(buffer.slice(6));
      const delta = json.choices?.[0]?.delta;
      if (delta?.content) {
        fullContent += delta.content;
        stdout.write(delta.content);
      }
    } catch {}
  }

  // Strip <think>...</think> blocks from content (model sometimes puts reasoning there)
  fullContent = fullContent.replace(/<think>[\s\S]*?<\/think>\s*/g, '');
  // Strip markdown fences
  fullContent = fullContent.replace(/^```\w*\n/gm, '').replace(/^```$/gm, '');

  stdout.write(fullContent);
  stdout.write('\n');
  if (fullReasoning) stderr.write('\n');

  return { content: fullContent, reasoning: fullReasoning };
}

async function main() {
  const opts = parseArgs();

  if (opts.prompt === '__STDIN__') {
    opts.prompt = await readStdin();
  }

  if (!opts.prompt) {
    stderr.write('Usage: node minimax.mjs "prompt" | --file file.txt | --stdin\n');
    process.exit(1);
  }

  await callAPI(opts.prompt, opts.system, opts.maxTokens, opts.temperature);
}

main().catch(e => {
  stderr.write(`Fatal: ${e.message}\n`);
  process.exit(1);
});
