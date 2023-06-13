#!/usr/bin/env node

const marked = require('marked')

const lines = []

process.stdin.on('data', (line) => {
  lines.push(line.toString())
})

process.stdin.on('close', () => {
  const json = JSON.parse(lines.join('\n'))
  const formatted = format(json)
  const formattedLines = JSON.stringify(formatted, null, '  ').split('\n')
  for (let line of formattedLines) {
    process.stdout.write(line + '\n', 'utf8')
  }
})

function format(node) {
  if (typeof node === 'object') {
    for (let key in node) {
      node[key] = format(node[key])
    }
  } else if (typeof node === 'string' && /(\*|_|- |\[)/.test(node)) {
    node = marked.parse(node).replace(/^<p>/, '').replace(/<\/p>\n$/, '')
  }
  return node
}
