import type { Metadata } from "next";
import { Phone, Mail, Clock, MapPin } from "lucide-react";
import ContactForm from "@/components/sections/ContactForm";

export const metadata: Metadata = {
  title: "Contact Us — EdTech OS",
  description:
    "Get in touch with the EdTech OS team. We're here to help you transform your institute.",
};

export default function ContactPage() {
  return (
    <section className="bg-white pt-4 pb-12 md:pt-6 md:pb-16">
      <div className="container-main">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12">
          {/* Left — Contact Info */}
          <div>
            <span className="badge-gold mb-4 inline-block">Contact Us</span>
            <h1 className="text-3xl sm:text-4xl font-display font-bold text-ink-green mt-4 mb-4">
              We&apos;d Love to Hear
              <br />
              <span className="text-gradient-gold">From You.</span>
            </h1>
            <p className="text-base text-ink-green/60 font-body leading-relaxed mb-8">
              Have questions about EdTech OS? Our team is here to help. Reach out
              and we&apos;ll get back to you as soon as possible.
            </p>

            <div className="space-y-5">
              {[
                {
                  icon: Phone,
                  label: "Phone",
                  value: "+91 98765 43210",
                  href: "tel:+919876543210",
                },
                {
                  icon: Mail,
                  label: "Email",
                  value: "support@edtechos.com",
                  href: "mailto:support@edtechos.com",
                },
                {
                  icon: Clock,
                  label: "Hours",
                  value: "Mon – Sat: 10:00 AM - 7:00 PM",
                },
                {
                  icon: MapPin,
                  label: "Address",
                  value: "Mumbai, Maharashtra, India",
                },
              ].map((item) => (
                <div key={item.label} className="flex items-start gap-3">
                  <div className="w-10 h-10 rounded-xl bg-chalk-teal/10 flex items-center justify-center flex-shrink-0">
                    <item.icon className="w-5 h-5 text-chalk-teal" />
                  </div>
                  <div>
                    <p className="text-xs text-ink-green/50 font-body uppercase tracking-wider">
                      {item.label}
                    </p>
                    {item.href ? (
                      <a
                        href={item.href}
                        className="text-sm font-body font-medium text-ink-green hover:text-brass-gold transition-colors"
                      >
                        {item.value}
                      </a>
                    ) : (
                      <p className="text-sm font-body font-medium text-ink-green">
                        {item.value}
                      </p>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Right — Contact Form */}
          <div className="bg-card-surface rounded-2xl shadow-card p-6 md:p-8">
            <h2 className="text-xl font-display font-bold text-ink-green mb-6">
              Send us a message
            </h2>
            <ContactForm />
          </div>
        </div>
      </div>
    </section>
  );
}
