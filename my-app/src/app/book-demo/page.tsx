import type { Metadata } from "next";
import { Clock, CheckCircle } from "lucide-react";

export const metadata: Metadata = {
  title: "Book a Free Demo — EdTech OS",
  description:
    "Schedule a free demo with our expert and see how EdTech OS can transform your coaching institute.",
};

export default function BookDemoPage() {
  return (
    <section className="bg-white pt-4 pb-12 md:pt-6 md:pb-16">
      <div className="container-main">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
          {/* Left — Info */}
          <div>
            <span className="badge-gold mb-4 inline-block">Free Demo</span>
            <h1 className="text-3xl sm:text-4xl font-display font-bold text-ink-green mt-4 mb-4">
              See EdTech OS
              <br />
              <span className="text-gradient-gold">In Action.</span>
            </h1>
            <p className="text-base text-ink-green/60 font-body leading-relaxed mb-8">
              Schedule a personalized demo with our expert. We&apos;ll show you
              exactly how EdTech OS can simplify your institute operations.
            </p>

            <div className="space-y-4">
              {[
                "Personalized walkthrough of all features",
                "See how your institute data will look",
                "Get answers to all your questions",
                "No commitment required",
              ].map((item) => (
                <div key={item} className="flex items-center gap-3">
                  <CheckCircle className="w-5 h-5 text-chalk-teal flex-shrink-0" />
                  <span className="text-sm font-body text-ink-green/70">
                    {item}
                  </span>
                </div>
              ))}
            </div>

            <div className="flex items-center gap-2 mt-6 text-sm text-ink-green/50 font-body">
              <Clock className="w-4 h-4" />
              Takes less than 30 seconds to book
            </div>
          </div>

          {/* Right — Booking Form */}
          <div className="bg-card-surface rounded-2xl shadow-card p-6 md:p-8">
            <h2 className="text-xl font-display font-bold text-ink-green mb-6">
              Book Your Free Demo
            </h2>
            <form className="space-y-4">
              <div>
                <label className="block text-sm font-body font-medium text-ink-green mb-1.5">
                  Institute Name
                </label>
                <input
                  type="text"
                  placeholder="e.g. Apex Academy"
                  className="w-full px-4 py-2.5 rounded-lg border border-paper bg-paper/50 text-sm font-body text-ink-green placeholder:text-ink-green/30 focus:outline-none focus:border-chalk-teal focus:ring-1 focus:ring-chalk-teal/20 transition-colors"
                />
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-body font-medium text-ink-green mb-1.5">
                    Your Name
                  </label>
                  <input
                    type="text"
                    placeholder="John Doe"
                    className="w-full px-4 py-2.5 rounded-lg border border-paper bg-paper/50 text-sm font-body text-ink-green placeholder:text-ink-green/30 focus:outline-none focus:border-chalk-teal focus:ring-1 focus:ring-chalk-teal/20 transition-colors"
                  />
                </div>
                <div>
                  <label className="block text-sm font-body font-medium text-ink-green mb-1.5">
                    Phone Number
                  </label>
                  <input
                    type="tel"
                    placeholder="+91 98765 43210"
                    className="w-full px-4 py-2.5 rounded-lg border border-paper bg-paper/50 text-sm font-body text-ink-green placeholder:text-ink-green/30 focus:outline-none focus:border-chalk-teal focus:ring-1 focus:ring-chalk-teal/20 transition-colors"
                  />
                </div>
              </div>
              <div>
                <label className="block text-sm font-body font-medium text-ink-green mb-1.5">
                  Email Address
                </label>
                <input
                  type="email"
                  placeholder="john@example.com"
                  className="w-full px-4 py-2.5 rounded-lg border border-paper bg-paper/50 text-sm font-body text-ink-green placeholder:text-ink-green/30 focus:outline-none focus:border-chalk-teal focus:ring-1 focus:ring-chalk-teal/20 transition-colors"
                />
              </div>
              <div>
                <label className="block text-sm font-body font-medium text-ink-green mb-1.5">
                  Number of Students
                </label>
                <select className="w-full px-4 py-2.5 rounded-lg border border-paper bg-paper/50 text-sm font-body text-ink-green focus:outline-none focus:border-chalk-teal focus:ring-1 focus:ring-chalk-teal/20 transition-colors">
                  <option>Select range</option>
                  <option>1 - 50</option>
                  <option>51 - 100</option>
                  <option>101 - 500</option>
                  <option>500+</option>
                </select>
              </div>
              <button
                type="submit"
                className="w-full bg-brass-gold text-white px-6 py-3 rounded-lg font-body font-semibold hover:bg-brass-gold/90 transition-colors flex items-center justify-center gap-2"
              >
                Book a Free Demo
                <span>→</span>
              </button>
            </form>
          </div>
        </div>
      </div>
    </section>
  );
}
