const headings = reduce(document.body, 'h2', (node => node.nextElementSibling))

const toc = document.getElementById('toc')

print(headings.slice(1))

function print(headings, parentLevels = ['toc']) {
  headings.map(h => {
    const el = document.createElement('div')
    const a = document.createElement('a')
    const levels = parentLevels.concat(h.textContent)
    el.className = `toc-item toc-item-level${levels.length - 1}`
    a.className = `toc-item-anchor`
    a.id = levels.map(s => s.toLowerCase().replace(/[^a-z]/g, '-')).join('.')
    a.href = '#' + a.id.split('.').slice(1).join('.')
    a.textContent = h.textContent
    el.appendChild(a)
    toc.appendChild(el)
    if (h._children) print(h._children, levels)
  })
}

function reduce(parent, selector, selectContainer) {
  const nodes = Array.from(parent.querySelectorAll(selector))

  return nodes.map(node => {
    const container = selectContainer(node)
    if (container) {
      const position = parseInt(node.tagName.charAt(1))
      if (position >= 5) {
        node._children = []
      } else {
        const childSelector = `h${position + 1}`
        const selectChildContainer = (node => node.parentElement.nextElementSibling)
        node._children = reduce(container, childSelector, selectChildContainer)
      }
    }
    return node
  })
}

console.log('HEADINGS', headings)
