import { useMemo, useState } from 'react'
import { categories, photos } from '../data.js'

const isMobile = () => window.innerWidth <= 520

export default function Gallery({ onOpen }) {
  const [active, setActive] = useState(() => isMobile() ? categories[1] : 'All')

  // Build one grid block per category so a row never mixes categories.
  // `flat` is the combined order used for lightbox prev/next navigation.
  const { groups, flat } = useMemo(() => {
    const cats = active === 'All' ? categories.filter((c) => c !== 'All') : [active]
    const flat = []
    const groups = []
    for (const cat of cats) {
      const items = photos.filter((p) => p.category === cat)
      if (!items.length) continue
      groups.push({ cat, start: flat.length, items })
      flat.push(...items)
    }
    return { groups, flat }
  }, [active])

  return (
    <section id="work" className="section gallery">
      <div className="section__head">
        <p className="section__eyebrow">Portfolio</p>
        <h2 className="section__title">Selected Work</h2>
      </div>

      <div className="gallery__filters" role="tablist" aria-label="Filter photos">
        {categories.map((cat) => (
          <button
            key={cat}
            role="tab"
            aria-selected={active === cat}
            className={`chip ${active === cat ? 'chip--active' : ''} ${cat === 'All' ? 'chip--all' : ''}`}
            onClick={() => setActive(cat)}
          >
            {cat}
          </button>
        ))}
      </div>

      {groups.map((group, i) => (
        <div key={group.cat}>
        {active === 'All' && i > 0 && (
          <div className="gallery__divider"><span>{group.cat}</span></div>
        )}
        {(() => {
          const sessions = []
          group.items.forEach((photo, j) => {
            const label = photo.session || ''
            const last = sessions[sessions.length - 1]
            if (!last || last.label !== label) {
              sessions.push({ label, items: [{ photo, j }] })
            } else {
              last.items.push({ photo, j })
            }
          })
          return sessions.map(({ label, items }) => (
            <div key={label || 'default'}>
              {label && <div className="gallery__session">{label}</div>}
              <div className="gallery__grid">
                {items.map(({ photo, j }) => (
                  <button
                    key={photo.id}
                    className="gallery__item"
                    onClick={() => onOpen(flat, group.start + j)}
                    aria-label={`Open ${photo.title}`}
                  >
                    <img src={photo.src} alt={photo.title} loading="lazy" />
                    <span className="gallery__caption">
                      <span className="gallery__cat">{photo.category}</span>
                      <span className="gallery__name">{photo.title}</span>
                    </span>
                  </button>
                ))}
              </div>
            </div>
          ))
        })()}
        </div>
      ))}

    </section>
  )
}
