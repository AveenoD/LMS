import React from "react";
import Image from "next/image";
import type { Metadata } from "next";
import {
  Users,
  GraduationCap,
  CalendarDays,
  Clock,
  BarChart3,
  Shield,
  Heart,
  Rocket,
  Layers,
  UserCircle2,
  Lightbulb,
  Headphones,
  Phone,
  MessageCircle,
  Globe,
  Share2,
  Mail,
  ArrowRight,
} from "lucide-react";
import Button from "@/components/ui/Button";

export const metadata: Metadata = {
  title: "About Us - EdTech OS",
  description:
    "Built by Educators, For Educators. Learn more about the mission and team behind EdTech OS.",
};

const STATS = [
  { icon: Users, stat: "1000+", label: "Institutes", sublabel: "Trust us" },
  {
    icon: GraduationCap,
    stat: "1M+",
    label: "Students",
    sublabel: "Empowered",
  },
  {
    icon: CalendarDays,
    stat: "5+ Years",
    label: "Of Excellence",
    sublabel: "In EdTech",
  },
];

const REASONS = [
  {
    icon: Clock,
    title: "Save Time",
    description: "Automate repetitive tasks and reduce manual work.",
  },
  {
    icon: BarChart3,
    title: "Improve Efficiency",
    description: "Manage everything in one powerful and easy platform.",
  },
  {
    icon: Shield,
    title: "Secure & Reliable",
    description: "Your data is safe with enterprise-grade security.",
  },
  {
    icon: Heart,
    title: "Delight Students",
    description: "Provide a better learning experience for students.",
  },
  {
    icon: Rocket,
    title: "Grow Faster",
    description: "Get insights and tools to scale your institute.",
  },
];

const TEAM = [
  {
    name: "Ankit Sharma",
    role: "Founder & CEO",
    description:
      "Passionate about education and technology. On a mission to empower institutes across India.",
    avatar: "/avatar_ankit.png",
  },
  {
    name: "Riya Patel",
    role: "Co-Founder & CTO",
    description:
      "Tech enthusiast with expertise in building scalable and secure platforms.",
    avatar: "/avatar_riya.png",
  },
  {
    name: "Manish Verma",
    role: "Head of Product",
    description:
      "Focused on creating simple, effective and impactful solutions for educators.",
    avatar: "/avatar_manish.png",
  },
  {
    name: "Neha Singh",
    role: "Customer Success Lead",
    description:
      "Dedicated to helping institutes get the best experience and achieve their goals.",
    avatar: "/avatar_neha.png",
  },
];

export default function AboutPage() {
  return (
    <main className="min-h-screen bg-paper overflow-hidden">
      {/* Hero Section */}
      <section className="pt-0 pb-12 md:pb-16 min-h-[calc(100vh-120px)] flex flex-col justify-center">
        <div className="container-main flex-grow flex flex-col justify-center">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-8 items-center">
            {/* Left Content */}
            <div className="max-w-xl">
              <div className="mb-6">
                <span className="badge-gold">
                  <span className="text-brass-gold uppercase tracking-wider text-[11px] font-bold">
                    Our Story
                  </span>
                </span>
              </div>
              <h1 className="text-4xl sm:text-5xl lg:text-[54px] font-display font-bold text-ink-green leading-[1.1] mb-2">
                Built by Educators,
              </h1>
              <h2 className="text-4xl sm:text-5xl lg:text-[54px] font-display font-bold text-brass-gold leading-[1.1] mb-6">
                For Educators.
              </h2>
              <p className="text-base sm:text-lg text-ink-green/70 font-body leading-relaxed mb-12 max-w-lg">
                EdTech OS was created with a simple mission — to simplify the daily
                operations of coaching institutes so they can focus on what matters
                most: teaching and growing students.
              </p>

              {/* Stats Row */}
              <div className="flex flex-col sm:flex-row gap-6 sm:gap-10">
                {STATS.map((stat, i) => (
                  <div key={i} className="flex gap-4 items-center">
                    <div className="w-14 h-14 rounded-full bg-ink-green text-white flex items-center justify-center flex-shrink-0">
                      <stat.icon className="w-6 h-6" />
                    </div>
                    <div className="flex flex-col">
                      <span className="font-display font-bold text-ink-green text-xl leading-tight">
                        {stat.stat}
                      </span>
                      <span className="font-body font-semibold text-ink-green text-sm leading-tight">
                        {stat.label}
                      </span>
                      <span className="font-body text-ink-green/60 text-xs">
                        {stat.sublabel}
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Right Image */}
            <div className="relative">
              <div className="relative w-full aspect-[4/3] rounded-3xl overflow-hidden shadow-card">
                <Image
                  src="/aboutus.png"
                  alt="EdTech OS Team"
                  fill
                  className="object-cover"
                  priority
                />
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Why We Built Section */}
      <section className="py-20 bg-white">
        <div className="container-main">
          <div className="text-center max-w-3xl mx-auto mb-16">
            <h2 className="text-3xl sm:text-4xl font-display font-bold text-ink-green mb-4 relative inline-block">
              Why We Built EdTech OS?
              <div className="absolute -bottom-2 left-1/2 -translate-x-1/2 w-16 h-1 bg-brass-gold rounded-full" />
            </h2>
            <p className="text-base text-ink-green/70 font-body mt-6">
              We saw the challenges coaching institutes face every day — managing
              students, attendance, fees, classes and communication using multiple
              tools and spreadsheets. We built EdTech OS to change that.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-5 gap-6">
            {REASONS.map((reason, i) => (
              <div
                key={i}
                className="bg-paper rounded-3xl p-6 text-center flex flex-col items-center hover:-translate-y-1 transition-transform duration-300"
              >
                <div className="w-16 h-16 rounded-full bg-white flex items-center justify-center text-ink-green shadow-sm mb-6 border border-ink-green/5">
                  <reason.icon className="w-7 h-7" strokeWidth={1.5} />
                </div>
                <h3 className="text-lg font-display font-bold text-ink-green mb-3">
                  {reason.title}
                </h3>
                <p className="text-sm text-ink-green/60 font-body leading-relaxed">
                  {reason.description}
                </p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* What Makes Us Different Section */}
      <section className="py-24 bg-paper">
        <div className="container-main">
          <div className="text-center mb-16">
            <h2 className="text-3xl sm:text-4xl font-display font-bold text-ink-green relative inline-block">
              What Makes Us Different?
              <div className="absolute -bottom-2 left-1/2 -translate-x-1/2 w-16 h-1 bg-brass-gold rounded-full" />
            </h2>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-[1fr_auto_1fr] gap-12 lg:gap-16 items-center max-w-5xl mx-auto">
            {/* Left Features */}
            <div className="flex flex-col gap-12 lg:text-right">
              <div className="flex lg:flex-row-reverse items-center lg:items-start gap-6">
                <div className="w-14 h-14 rounded-full bg-ink-green text-white flex items-center justify-center flex-shrink-0">
                  <Layers className="w-6 h-6" />
                </div>
                <div>
                  <h3 className="text-xl font-display font-bold text-ink-green mb-2">
                    All-in-One Platform
                  </h3>
                  <p className="text-sm text-ink-green/70 font-body leading-relaxed">
                    Everything you need to run your institute in one place — from
                    admission to reports.
                  </p>
                </div>
              </div>
              <div className="flex lg:flex-row-reverse items-center lg:items-start gap-6">
                <div className="w-14 h-14 rounded-full bg-brass-gold text-white flex items-center justify-center flex-shrink-0">
                  <UserCircle2 className="w-6 h-6" />
                </div>
                <div>
                  <h3 className="text-xl font-display font-bold text-ink-green mb-2">
                    User Friendly
                  </h3>
                  <p className="text-sm text-ink-green/70 font-body leading-relaxed">
                    Designed for educators, easy to use for everyone on your team.
                  </p>
                </div>
              </div>
            </div>

            {/* Center Logo Graphic */}
            <div className="hidden lg:flex justify-center relative">
              <div className="w-[280px] h-[280px] rounded-full border border-ink-green/10 flex items-center justify-center relative">
                {/* Decorative circles */}
                <div className="absolute top-1/4 -left-4 w-4 h-4 rounded-full border border-brass-gold/40" />
                <div className="absolute top-1/4 -right-4 w-4 h-4 rounded-full border border-brass-gold/40" />
                <div className="absolute bottom-1/3 -left-8 w-6 h-6 rounded-full border border-ink-green/20" />
                <div className="absolute bottom-1/3 -right-8 w-6 h-6 rounded-full border border-ink-green/20" />

                <Image
                  src="/footer-logo.png"
                  alt="EdTech OS Shield"
                  width={200}
                  height={200}
                  className="object-contain drop-shadow-2xl"
                />
              </div>
            </div>

            {/* Right Features */}
            <div className="flex flex-col gap-12">
              <div className="flex items-center lg:items-start gap-6">
                <div className="w-14 h-14 rounded-full bg-brass-gold text-white flex items-center justify-center flex-shrink-0">
                  <Lightbulb className="w-6 h-6" />
                </div>
                <div>
                  <h3 className="text-xl font-display font-bold text-ink-green mb-2">
                    Continuous Innovation
                  </h3>
                  <p className="text-sm text-ink-green/70 font-body leading-relaxed">
                    We keep adding new features and improvements based on your
                    feedback.
                  </p>
                </div>
              </div>
              <div className="flex items-center lg:items-start gap-6">
                <div className="w-14 h-14 rounded-full bg-ink-green text-white flex items-center justify-center flex-shrink-0">
                  <Headphones className="w-6 h-6" />
                </div>
                <div>
                  <h3 className="text-xl font-display font-bold text-ink-green mb-2">
                    Dedicated Support
                  </h3>
                  <p className="text-sm text-ink-green/70 font-body leading-relaxed">
                    Our support team is always here to help you succeed.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Team Section */}
      <section className="py-20 bg-white">
        <div className="container-main">
          <div className="text-center mb-16">
            <h2 className="text-3xl sm:text-4xl font-display font-bold text-ink-green relative inline-block">
              Meet The People Behind EdTech OS
              <div className="absolute -bottom-2 left-1/2 -translate-x-1/2 w-16 h-1 bg-brass-gold rounded-full" />
            </h2>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8">
            {TEAM.map((member) => (
              <div
                key={member.name}
                className="bg-paper border border-ink-green/5 rounded-3xl p-8 flex flex-col items-center text-center hover:shadow-card transition-shadow duration-300"
              >
                <div className="w-24 h-24 rounded-full bg-ink-green/5 border-2 border-white shadow-sm overflow-hidden mb-6 relative">
                  <Image
                    src={member.avatar}
                    alt={member.name}
                    fill
                    className="object-cover"
                  />
                </div>
                <h3 className="text-lg font-display font-bold text-ink-green mb-1">
                  {member.name}
                </h3>
                <p className="text-sm font-semibold text-brass-gold mb-4">
                  {member.role}
                </p>
                <p className="text-sm text-ink-green/70 font-body leading-relaxed mb-6">
                  {member.description}
                </p>
                <div className="flex items-center gap-4 mt-auto">
                  <a href="#" className="text-ink-green/40 hover:text-ink-green transition-colors">
                    <Globe className="w-4 h-4" />
                  </a>
                  <a href="#" className="text-ink-green/40 hover:text-ink-green transition-colors">
                    <Share2 className="w-4 h-4" />
                  </a>
                  <a href="#" className="text-ink-green/40 hover:text-ink-green transition-colors">
                    <Mail className="w-4 h-4" />
                  </a>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Bottom CTA Banner */}
      <section className="py-20 bg-paper">
        <div className="container-main">
          <div className="bg-ink-green rounded-3xl p-8 sm:p-12 relative overflow-hidden flex flex-col lg:flex-row items-center justify-between gap-10 shadow-card">
            {/* Pattern overlay */}
            <div className="absolute inset-0 bg-white/[0.02] bg-[url('https://www.transparenttextures.com/patterns/cubes.png')] pointer-events-none" />

            <div className="flex items-center gap-8 z-10 w-full lg:w-auto">
              {/* Avatar/Monitor Illustration */}
              <div className="w-24 h-24 sm:w-32 sm:h-32 rounded-2xl overflow-hidden flex-shrink-0 bg-white/5 border border-white/10 hidden sm:block relative">
                <Image
                  src="/cta_monitor.png"
                  alt="Dashboard Platform"
                  fill
                  className="object-cover"
                />
              </div>
              <div>
                <h2 className="text-2xl sm:text-3xl lg:text-4xl font-display font-bold text-white mb-3">
                  Let's Build the Future of Education Together
                </h2>
                <p className="text-sm sm:text-base text-white/70 font-body max-w-lg">
                  Join 1000+ coaching institutes that trust EdTech OS to run and
                  grow their business.
                </p>
              </div>
            </div>

            <div className="flex flex-col sm:flex-row items-center gap-4 z-10 w-full lg:w-auto shrink-0">
              <Button
                variant="primary"
                size="lg"
                href="/demo"
                className="w-full sm:w-auto justify-center"
              >
                Book a Free Demo <ArrowRight className="w-4 h-4 ml-2" />
              </Button>
              <a
                href="tel:+919876543210"
                className="flex items-center gap-3 px-6 py-4 border border-white/20 rounded-xl text-white hover:bg-white/10 transition-colors w-full sm:w-auto justify-center"
              >
                <Phone className="w-5 h-5" />
                <span className="text-sm font-semibold font-body">Talk to Expert</span>
              </a>
            </div>
          </div>
        </div>
      </section>
    </main>
  );
}
