import { useEffect, useState, useCallback } from 'react'

export default function Lightbox({ list, index, onClose }) {
  const [i, setI] = useState(index)
  const photo = list[i]
  const many = list.length > 1

  const prev = useCallback(
    () => setI((v) => (v - 1 + list.length) % list.length),
    [list.length],
  )
  const next = useCallback(
    () => setI((v) => (v + 1) % list.length),
    [list.length],
  )

  useEffect(() => {
    const onKey = (e) => {
      if (e.key === 'Escape') onClose()
      else if (e.key === 'ArrowLeft') prev()
      else if (e.key === 'ArrowRight') next()
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [onClose, prev, next])

  return (
    <div className="lightbox" onClick={onClose} role="dialog" aria-modal="true" aria-label={photo.title}>
      <button className="lightbox__close" onClick={onClose} aria-label="Close">×</button>

      {many && (
        <button
          className="lightbox__nav lightbox__nav--prev"
          onClick={(e) => { e.stopPropagation(); prev() }}
          aria-label="Previous photo"
        >‹</button>
      )}

      <figure className="lightbox__figure" onClick={(e) => e.stopPropagation()}>
        <img src={photo.src} alt={photo.title} />
        <figcaption className="lightbox__caption">
          <span className="gallery__cat">{photo.category}</span>
          <span>{photo.title}</span>
          {many && <span className="lightbox__count">{i + 1} / {list.length}</span>}
        </figcaption>
      </figure>

      {many && (
        <button
          className="lightbox__nav lightbox__nav--next"
          onClick={(e) => { e.stopPropagation(); next() }}
          aria-label="Next photo"
        >›</button>
      )}
    </div>
  )
}
