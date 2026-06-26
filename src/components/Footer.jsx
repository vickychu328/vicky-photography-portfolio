import { photographer } from '../data.js'

export default function Footer() {
  return (
    <footer className="footer">
      <div className="footer__inner">
        <div>
          <p className="footer__brand">{photographer.name}</p>
          <p className="footer__tag">{photographer.tagline}</p>
        </div>
        <div className="footer__links">
          <a href={`mailto:${photographer.email}`}>{photographer.email}</a>
          <a href={`https://instagram.com/${photographer.instagram.replace('@', '')}`} target="_blank" rel="noreferrer">
            {photographer.instagram}
          </a>
          <span>{photographer.location}</span>
        </div>
      </div>
      <p className="footer__copy">
        © {new Date().getFullYear()} {photographer.name}. All rights reserved.
      </p>
    </footer>
  )
}
