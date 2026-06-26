# Vicky Chu · Photography

A portfolio + booking website built with React + Vite for Vicky Chu — a Seattle-based
photographer specializing in pre-wedding, couples, graduation, and other occasion shoots.

## Run it

```bash
npm install      # first time only
npm run dev      # start the dev server → http://localhost:5173
npm run build    # production build into dist/
npm run preview  # preview the production build
```

> Requires Node.js (installed via `brew install node` on this machine).

## Customize

Almost everything lives in **`src/data.js`**:

- **`photographer`** — name, tagline, location, email, Instagram handle.
- **`categories`** — the gallery filter chips (also drive the booking form's occasion list).
- **`photos`** — each entry has `category`, `title`, and `src`.
- **`services`** — the pricing cards.

### Use your own photos
1. Drop image files into `public/photos/` (create the folder).
2. In `src/data.js`, set `src: "/photos/your-file.jpg"` for each photo.
3. The hero and about-section images are set in `src/index.css` (`.hero` background) and
   `src/components/About.jsx`.

## Booking form

The form in `src/components/Booking.jsx` is **front-end only** — on submit it opens the
visitor's email client (`mailto:`) addressed to the photographer. To collect enquiries
automatically (no email client needed), follow the commented instructions at the top of
`onSubmit` to POST to a form service like Formspree or EmailJS.

## Structure

```
src/
  data.js              ← edit this for content
  App.jsx              ← page composition + lightbox state
  index.css            ← all styling
  components/
    Navbar, Hero, Gallery, Lightbox, About, Services, Booking, Footer
```
