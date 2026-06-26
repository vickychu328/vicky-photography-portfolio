import { photographer } from '../data.js'

export default function Hero() {
  return (
    <section id="top" className="hero">
      <div className="hero__overlay" />
      <div className="hero__content">
        <p className="hero__eyebrow">Based in {photographer.location}</p>
        <h1 className="hero__title">{photographer.name}</h1>
        <p className="hero__tagline">{photographer.tagline}</p>
        <div className="hero__actions">
          <a className="btn btn--solid" href="#work">View Work</a>
          <a className="btn btn--ghost" href="#contact">Contact</a>
        </div>
      </div>
      <a className="hero__scroll" href="#work" aria-label="Scroll to work">↓</a>
    </section>
  )
}
