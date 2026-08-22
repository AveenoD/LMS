import React from "react";
import Image from "next/image";
import type { Metadata } from "next";
import {
  Calendar,
  Scissors,
  MessageSquare,
  Play,
  Shield,
  Building,
  GraduationCap,
  BookOpen,
  Microscope,
  Trophy,
  LayoutDashboard,
  Users,
  CreditCard,
  Video,
  FileText,
  Settings,
  Phone,
  MessageCircle,
} from "lucide-react";
import Button from "@/components/ui/Button";
import TrustBadge from "@/components/ui/TrustBadge";
import DemoBookingForm from "@/components/sections/DemoBookingForm";

export const metadata: Metadata = {
  title: "Book a Demo - EdTech OS",
  description:
    "See EdTech OS in action and discover how it can simplify operations, save time, and help your institute grow.",
};

const DEMO_TRUST_BADGES = [
  { icon: Shield, title: "APEX ACADEMY", subtitle: "Nashik" },
  { icon: Building, title: "BRIGHT FUTURE", subtitle: "Pune" },
  { icon: GraduationCap, title: "SUCCESS POINT", subtitle: "Nagpur" },
  { icon: BookOpen, title: "SCHOLAR'S HUB", subtitle: "Aurangabad" },
  { icon: Microscope, title: "THE LEARNING LAB", subtitle: "Mumbai" },
  { icon: Trophy, title: "VISION CLASSES", subtitle: "Solapur" },
];

const DEMO_FEATURES = [
  {
    icon: LayoutDashboard,
    title: "Institute Dashboard",
    description: "Get a complete overview of your institute.",
  },
  {
    icon: Users,
    title: "Students & Attendance",
    description: "Manage students and track attendance easily.",
  },
  {
    icon: CreditCard,
    title: "Fees Management",
    description: "Collect fees online and manage payments.",
  },
  {
    icon: Video,
    title: "Live Classes",
    description: "Conduct and manage live classes seamlessly.",
  },
  {
    icon: FileText,
    title: "Tests & Reports",
    description: "Create tests and analyze performance.",
  },
  {
    icon: Settings,
    title: "Settings & Customization",
    description: "Customize your institute the way you want.",
  },
];

export default function DemoPage() {
  return (
    <main className="min-h-screen bg-paper">
      {/* Hero Section */}
      <section className="pt-4 pb-12 md:pt-6 md:pb-16 min-h-[calc(100vh-120px)] flex flex-col justify-center overflow-hidden">
        <div className="container-main flex-grow flex flex-col justify-center">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-8 items-center">
            {/* Left Content */}
            <div className="max-w-xl">
              <h1 className="text-4xl sm:text-5xl lg:text-[54px] font-display font-bold text-ink-green leading-[1.1] mb-2">
                See EdTech OS in Action
              </h1>
              <h2 className="text-3xl sm:text-4xl lg:text-[46px] font-display font-bold text-brass-gold leading-[1.1] mb-6">
                A Quick Demo for You.
              </h2>
              <p className="text-base sm:text-lg text-ink-green/70 font-body leading-relaxed mb-10">
                Explore how EdTech OS can simplify operations, save time and
                help your institute grow.
              </p>

              {/* Bullet Points */}
              <div className="space-y-6 mb-10">
                <div className="flex gap-4 items-start">
                  <div className="w-12 h-12 rounded-2xl bg-white shadow-sm flex items-center justify-center flex-shrink-0 text-ink-green border border-ink-green/5">
                    <Calendar className="w-6 h-6" />
                  </div>
                  <div>
                    <h3 className="text-lg font-display font-bold text-ink-green mb-1">
                      Live Platform Walkthrough
                    </h3>
                    <p className="text-sm text-ink-green/60 font-body">
                      See how everything works step by step.
                    </p>
                  </div>
                </div>
                <div className="flex gap-4 items-start">
                  <div className="w-12 h-12 rounded-2xl bg-white shadow-sm flex items-center justify-center flex-shrink-0 text-ink-green border border-ink-green/5">
                    <Scissors className="w-6 h-6" />
                  </div>
                  <div>
                    <h3 className="text-lg font-display font-bold text-ink-green mb-1">
                      Tailored to Your Needs
                    </h3>
                    <p className="text-sm text-ink-green/60 font-body">
                      Get a demo customized for your institute.
                    </p>
                  </div>
                </div>
                <div className="flex gap-4 items-start">
                  <div className="w-12 h-12 rounded-2xl bg-white shadow-sm flex items-center justify-center flex-shrink-0 text-ink-green border border-ink-green/5">
                    <MessageSquare className="w-6 h-6" />
                  </div>
                  <div>
                    <h3 className="text-lg font-display font-bold text-ink-green mb-1">
                      Ask Questions, Get Answers
                    </h3>
                    <p className="text-sm text-ink-green/60 font-body">
                      Our experts are here to help you decide.
                    </p>
                  </div>
                </div>
              </div>

              {/* CTAs */}
              <div className="flex flex-wrap items-center gap-4">
                <Button variant="primary" size="lg" href="#demo-form" withArrow>
                  Book a Free Demo
                </Button>
                <Button
                  variant="secondary"
                  size="lg"
                  className="bg-white border-ink-green/20 hover:border-ink-green hover:bg-ink-green/5 text-ink-green"
                >
                  <Play className="w-4 h-4" />
                  Watch Demo Video
                </Button>
              </div>
            </div>

            {/* Right Dashboard Mockup */}
            <div className="relative">
              <div className="relative w-full aspect-[4/3] max-w-[700px] mx-auto lg:ml-auto">
                <Image
                  src="/demo-page.png"
                  alt="EdTech OS Dashboard"
                  fill
                  className="object-contain drop-shadow-2xl mix-blend-multiply"
                  priority
                />
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Trusted By Strip */}
      <section className="border-y border-ink-green/10 bg-white/50 backdrop-blur-sm py-8">
        <div className="container-main">
          <p className="text-center text-brass-gold font-body font-semibold mb-6">
            Trusted by 1000+ Coaching Institutes
          </p>
          <div className="flex flex-wrap justify-center md:justify-between items-center gap-6 opacity-70">
            {DEMO_TRUST_BADGES.map((badge) => (
              <div
                key={badge.title}
                className="flex items-center gap-3 grayscale hover:grayscale-0 transition-all duration-300"
              >
                <badge.icon className="w-8 h-8 text-ink-green" />
                <div className="flex flex-col">
                  <span className="text-xs font-display font-bold text-ink-green leading-tight">
                    {badge.title}
                  </span>
                  <span className="text-[10px] text-ink-green/60 font-body">
                    {badge.subtitle}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Split Section: Features & Form */}
      <section className="py-20 bg-paper">
        <div className="container-main">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-16 lg:gap-12">
            {/* Left: Included Features */}
            <div>
              <h2 className="text-2xl sm:text-3xl font-display font-bold text-ink-green mb-10">
                What's Included in the Demo?
              </h2>
              <div className="space-y-8">
                {DEMO_FEATURES.map((feature) => (
                  <div key={feature.title} className="flex gap-4 items-start">
                    <div className="w-12 h-12 rounded-full bg-chalk-teal/10 flex items-center justify-center flex-shrink-0 text-chalk-teal border border-chalk-teal/20">
                      <feature.icon className="w-5 h-5" />
                    </div>
                    <div>
                      <h3 className="text-lg font-display font-bold text-ink-green mb-1">
                        {feature.title}
                      </h3>
                      <p className="text-sm text-ink-green/60 font-body">
                        {feature.description}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Right: Booking Form */}
            <div id="demo-form" className="relative">
              <div className="bg-white rounded-3xl p-8 sm:p-10 shadow-card border border-ink-green/5">
                <h3 className="text-2xl font-display font-bold text-ink-green mb-2">
                  Book Your Free Demo
                </h3>
                <p className="text-sm text-ink-green/60 font-body mb-8">
                  Fill in your details and our expert will connect with you.
                </p>

                <DemoBookingForm />
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Bottom CTA Banner */}
      <section className="pb-20 bg-paper">
        <div className="container-main">
          <div className="bg-ink-green rounded-3xl p-8 sm:p-12 relative overflow-hidden flex flex-col md:flex-row items-center justify-between gap-8 shadow-card">
            {/* Pattern overlay */}
            <div className="absolute inset-0 bg-white/[0.02] bg-[url('https://www.transparenttextures.com/patterns/cubes.png')] pointer-events-none" />

            <div className="flex items-center gap-6 z-10 w-full md:w-auto">
              {/* Avatar Illustration */}
              <div className="w-24 h-24 sm:w-32 sm:h-32 rounded-full overflow-hidden flex-shrink-0 bg-chalk-teal border-4 border-white/10 hidden sm:block relative">
                <Image
                  src="/support_avatar.png"
                  alt="EdTech OS Support Expert"
                  fill
                  className="object-cover"
                />
              </div>
              <div>
                <h2 className="text-2xl sm:text-3xl font-display font-bold text-white mb-2">
                  Still have questions?
                </h2>
                <p className="text-sm sm:text-base text-white/70 font-body max-w-sm">
                  Talk to our LMS experts and find the perfect solution for your
                  institute.
                </p>
              </div>
            </div>

            <div className="flex flex-col sm:flex-row items-center gap-4 z-10 w-full md:w-auto">
              <a
                href="tel:+919876543210"
                className="flex items-center gap-3 px-6 py-4 border border-white/20 rounded-2xl text-white hover:bg-white/10 transition-colors w-full sm:w-auto justify-center"
              >
                <div className="p-2 bg-white/10 rounded-lg">
                  <Phone className="w-5 h-5" />
                </div>
                <div className="flex flex-col">
                  <span className="text-xs text-white/70 font-body">Talk to Expert</span>
                  <span className="text-sm font-semibold font-body">+91 98765 43210</span>
                </div>
              </a>
              <a
                href="https://wa.me/919876543210"
                className="flex items-center gap-3 px-6 py-4 border border-white/20 rounded-2xl text-white hover:bg-white/10 transition-colors w-full sm:w-auto justify-center"
              >
                <div className="p-2 bg-white/10 rounded-lg">
                  <MessageCircle className="w-5 h-5" />
                </div>
                <span className="text-sm font-semibold font-body">Chat on WhatsApp</span>
              </a>
            </div>
          </div>
        </div>
      </section>
    </main>
  );
}
