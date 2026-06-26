import { services, servicesNote } from '../data.js'

export default function Services() {
  return (
    <section id="services" className="section services">
      <div className="section__head">
        <p className="section__eyebrow">Services</p>
        <h2 className="section__title">Sessions & Pricing</h2>
      </div>
      <div className="services__grid">
        {services.map((s) => (
          <article key={s.title} className="service-card">
            <h3>{s.title}</h3>
            <p className="service-card__price">{s.price}</p>
            {s.desc && <p className="service-card__desc">{s.desc}</p>}
            {s.features ? (
              <ul className="service-card__features">
                {s.features.map((f) => (
                  <li key={f}>{f}</li>
                ))}
              </ul>
            ) : (
              <p className="service-card__blurb">{s.blurb}</p>
            )}
            <a className="service-card__link service-card__link--contact" href="#contact">Contact →</a>
          </article>
        ))}
      </div>
      <p className="services__note">{servicesNote}</p>
    </section>
  )
}
