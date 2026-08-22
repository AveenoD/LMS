import type { Metadata } from "next";
import { Clock, CheckCircle } from "lucide-react";
import BookDemoForm from "@/components/sections/BookDemoForm";

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
            <BookDemoForm />
          </div>
        </div>
      </div>
    </section>
  );
}
