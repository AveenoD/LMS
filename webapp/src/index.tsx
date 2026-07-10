import { Hono } from 'hono'
import { renderer } from './renderer'
import { PricingTable } from './components/PricingTable'

const app = new Hono()

app.use(renderer)

app.get('/', (c) => {
  return c.render(
    <div>
      <h1 style={{ textAlign: 'center', marginTop: '2rem' }}>EdTech OS Marketing</h1>
      <p style={{ textAlign: 'center' }}>Welcome to EdTech OS.</p>
    </div>
  )
})

app.get('/pricing', async (c) => {
  try {
    // In production, this URL should point to your actual backend API
    const res = await fetch('http://localhost:4000/api/v1/public/plans')
    if (!res.ok) {
      throw new Error('Failed to fetch plans')
    }
    const data = await res.json() as any
    const plans = data.data || []
    
    return c.render(
      <PricingTable plans={plans} />
    )
  } catch (error) {
    return c.render(
      <div style={{ textAlign: 'center', padding: '2rem' }}>
        <h2 style={{ color: 'red' }}>Error loading pricing plans</h2>
        <p>Please try again later.</p>
      </div>
    )
  }
})

export default app
