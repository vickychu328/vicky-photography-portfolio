import { useState, useEffect, useCallback } from 'react'
import Navbar from './components/Navbar.jsx'
import Hero from './components/Hero.jsx'
import Gallery from './components/Gallery.jsx'
import About from './components/About.jsx'
import Services from './components/Services.jsx'
import Booking from './components/Booking.jsx'
import Footer from './components/Footer.jsx'
import Lightbox from './components/Lightbox.jsx'

export default function App() {
  const [lightbox, setLightbox] = useState(null)
  const [showTop, setShowTop] = useState(false)

  useEffect(() => {
    document.body.style.overflow = lightbox ? 'hidden' : ''
  }, [lightbox])

  useEffect(() => {
    const onScroll = () => setShowTop(window.scrollY > 400)
    window.addEventListener('scroll', onScroll)
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  return (
    <>
      <Navbar />
      <main>
        <Hero />
        <Gallery onOpen={(list, index) => setLightbox({ list, index })} />
        <About />
        <Services />
        <Booking />
      </main>
      <Footer />
      {showTop && (
        <a href="#top" className="backtop" aria-label="Back to top">↑</a>
      )}
      {lightbox && (
        <Lightbox
          list={lightbox.list}
          index={lightbox.index}
          onClose={() => setLightbox(null)}
        />
      )}
    </>
  )
}
