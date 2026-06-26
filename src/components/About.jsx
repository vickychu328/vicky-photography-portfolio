import { photographer, portrait } from '../data.js'

export default function About() {
  return (
    <section id="about" className="section about">
      <div className="about__image">
        <img src={portrait} alt={photographer.name} loading="lazy" />
      </div>
      <div className="about__text">
        <p className="section__eyebrow">About</p>
        <h2 className="section__title">Hi, I’m {photographer.name.split(' ')[0]}</h2>
        <p>
          I’m a {photographer.location}-based photographer who loves capturing genuine moments
          and meaningful connections. Whether it’s a graduation milestone, a couple’s adventure,
          a family gathering, or a pre-wedding session, my goal is to create images that feel
          natural, timeless, and true to you.
        </p>
        <p>
          I believe the best photos come from feeling comfortable in front of the camera. That’s
          why I focus on creating a relaxed, enjoyable experience while documenting the moments
          you’ll want to remember for years to come.
        </p>
        <ul className="about__stats">
          <li><strong>10 yrs</strong><span>photography journey</span></li>
          <li><strong>{photographer.location}</strong><span>based</span></li>
        </ul>
      </div>
    </section>
  )
}
