import { useState } from 'react'
import { services, photographer } from '../data.js'

const sessionTypes = services.map((s) => s.title)

const empty = { name: '', email: '', phone: '', sessionType: sessionTypes[0], date: '', location: '', referral: '', message: '' }

export default function Booking() {
  const [form, setForm] = useState(empty)
  const [errors, setErrors] = useState({})
  const [sent, setSent] = useState(false)

  const update = (e) => setForm({ ...form, [e.target.name]: e.target.value })

  const validate = () => {
    const next = {}
    if (!form.name.trim()) next.name = 'Please enter your name.'
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email)) next.email = 'Enter a valid email.'
    if (!form.date) next.date = 'Pick a preferred date.'
    setErrors(next)
    return Object.keys(next).length === 0
  }

  const onSubmit = (e) => {
    e.preventDefault()
    if (!validate()) return

    const subject = encodeURIComponent(`Booking enquiry — ${form.sessionType}`)
    const body = encodeURIComponent(
      `Name: ${form.name}\nEmail: ${form.email}\nPhone: ${form.phone || 'N/A'}\n` +
        `Session type: ${form.sessionType}\nPreferred date: ${form.date}\n` +
        `Preferred location: ${form.location || 'N/A'}\nHow they heard about me: ${form.referral || 'N/A'}\n\n${form.message}`,
    )
    window.location.href = `mailto:${photographer.email}?subject=${subject}&body=${body}`

    setSent(true)
    setForm(empty)
  }

  return (
    <section id="contact" className="section booking">
      <div className="booking__head">
        <p className="section__eyebrow">Contact</p>
        <h2 className="section__title">Let's create something together</h2>
        <p className="booking__sub">
          Tell me about your vision, and I'll get back to you within 1–2 business days.
        </p>
      </div>

      {sent ? (
        <div className="booking__success" role="status">
          <h3>Thank you! 🎉</h3>
          <p>
            Your enquiry is on its way. If your email client didn't open, reach me directly at{' '}
            <a href={`mailto:${photographer.email}`}>{photographer.email}</a>.
          </p>
          <button className="btn btn--ghost" onClick={() => setSent(false)}>
            Send another
          </button>
        </div>
      ) : (
        <form className="booking__form" onSubmit={onSubmit} noValidate>
          <div className="field">
            <label htmlFor="name">Name</label>
            <input id="name" name="name" value={form.name} onChange={update} />
            {errors.name && <span className="field__error">{errors.name}</span>}
          </div>

          <div className="field">
            <label htmlFor="email">Email</label>
            <input id="email" name="email" type="email" value={form.email} onChange={update} />
            {errors.email && <span className="field__error">{errors.email}</span>}
          </div>

          <div className="field">
            <label htmlFor="phone">Phone number</label>
            <input id="phone" name="phone" type="tel" value={form.phone} onChange={update} placeholder="Optional" />
          </div>

          <div className="field">
            <label htmlFor="sessionType">Session type</label>
            <select id="sessionType" name="sessionType" value={form.sessionType} onChange={update}>
              {sessionTypes.map((o) => (
                <option key={o} value={o}>{o}</option>
              ))}
            </select>
          </div>

          <div className="field">
            <label htmlFor="date">Preferred date</label>
            <input id="date" name="date" type="date" value={form.date} onChange={update} />
            {errors.date && <span className="field__error">{errors.date}</span>}
          </div>

          <div className="field">
            <label htmlFor="location">Preferred location</label>
            <input id="location" name="location" value={form.location} onChange={update} placeholder="Optional" />
          </div>

          <div className="field field--full">
            <label htmlFor="referral">How did you hear about me? <span className="field__optional">(optional)</span></label>
            <input id="referral" name="referral" value={form.referral} onChange={update} />
          </div>

          <div className="field field--full">
            <label htmlFor="message">Tell me about your shoot</label>
            <textarea
              id="message" name="message" rows="4"
              value={form.message} onChange={update}
              placeholder="Tell me a little about your vision, preferred location, number of people, and any ideas you have. Pinterest boards and inspiration are welcome!"
            />
          </div>

          <button type="submit" className="btn btn--solid field--full">Book Your Session</button>
        </form>
      )}
    </section>
  )
}
