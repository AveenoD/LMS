import { FC } from 'hono/jsx'

type Plan = {
  id: string;
  name: string;
  price_monthly: string | number;
  features: string[];
  is_recommended?: boolean;
}

export const PricingTable: FC<{ plans: Plan[] }> = ({ plans }) => {
  return (
    <div style={{ padding: '2rem', fontFamily: 'sans-serif', backgroundColor: '#f9fafb' }}>
      <div style={{ textAlign: 'center', marginBottom: '3rem' }}>
        <h2 style={{ fontSize: '2.5rem', color: '#111827', marginBottom: '1rem' }}>Simple, Transparent Pricing</h2>
        <p style={{ fontSize: '1.125rem', color: '#6b7280' }}>Pay Only For Your Active Students.</p>
      </div>

      <div style={{ display: 'flex', gap: '2rem', justifyContent: 'center', flexWrap: 'wrap', maxWidth: '1200px', margin: '0 auto' }}>
        {plans.map((plan) => (
          <div 
            style={{ 
              backgroundColor: 'white', 
              borderRadius: '1rem', 
              padding: '2rem',
              boxShadow: plan.is_recommended ? '0 20px 25px -5px rgba(0, 0, 0, 0.1)' : '0 4px 6px -1px rgba(0, 0, 0, 0.1)',
              border: plan.is_recommended ? '2px solid #fbbf24' : '1px solid #e5e7eb',
              flex: '1 1 300px',
              maxWidth: '350px',
              position: 'relative'
            }}
          >
            {plan.is_recommended && (
              <div style={{
                position: 'absolute',
                top: '-12px',
                right: '1rem',
                backgroundColor: '#fbbf24',
                color: 'white',
                padding: '0.25rem 0.75rem',
                borderRadius: '9999px',
                fontSize: '0.75rem',
                fontWeight: 'bold'
              }}>
                MOST POPULAR
              </div>
            )}
            <h3 style={{ fontSize: '1.5rem', color: '#10b981', marginBottom: '0.5rem', marginTop: '0' }}>{plan.name}</h3>
            <div style={{ display: 'flex', alignItems: 'flex-end', marginBottom: '1.5rem' }}>
              <span style={{ fontSize: '3rem', fontWeight: 'bold', color: '#10b981', lineHeight: '1' }}>₹{plan.price_monthly}</span>
              <span style={{ color: '#6b7280', marginLeft: '0.25rem', marginBottom: '0.5rem' }}>/student/month</span>
            </div>
            
            <hr style={{ border: 'none', borderTop: '1px solid #e5e7eb', marginBottom: '1.5rem' }} />
            
            <ul style={{ listStyle: 'none', padding: 0, margin: 0, marginBottom: '2rem' }}>
              {plan.features.map(feature => (
                <li style={{ display: 'flex', alignItems: 'center', marginBottom: '0.75rem' }}>
                  <svg style={{ width: '1.25rem', height: '1.25rem', color: '#10b981', marginRight: '0.75rem' }} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 13l4 4L19 7"></path>
                  </svg>
                  <span style={{ color: '#374151' }}>{feature}</span>
                </li>
              ))}
            </ul>
            
            <button style={{
              width: '100%',
              backgroundColor: '#10b981',
              color: 'white',
              padding: '0.75rem 1rem',
              borderRadius: '0.5rem',
              border: 'none',
              fontSize: '1rem',
              fontWeight: '600',
              cursor: 'pointer'
            }}>
              Get Started
            </button>
          </div>
        ))}
      </div>
    </div>
  )
}
