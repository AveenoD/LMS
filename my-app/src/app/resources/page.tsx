import React from "react";
import type { Metadata } from "next";
import Image from "next/image";
import { Search, ArrowRight, CheckCircle2, Send } from "lucide-react";
import ResourceCategoryCard from "@/components/ui/ResourceCategoryCard";
import ResourceArticleCard from "@/components/ui/ResourceArticleCard";
import {
  RESOURCE_CATEGORIES,
  LATEST_RESOURCES,
  POPULAR_TOPICS,
} from "@/utils/constants";
import Button from "@/components/ui/Button";

export const metadata: Metadata = {
  title: "Resources | EdTech OS",
  description: "Guides, blogs, templates and webinars for coaching institutes.",
};

export default function ResourcesPage() {
  return (
    <div className="flex flex-col min-h-screen pt-0 bg-paper/30">
      {/* 1. Hero Section */}
      <section className="relative overflow-hidden pt-4 md:pt-6 pb-12 md:pb-16 min-h-[calc(100vh-120px)] flex flex-col justify-center">
        <div className="container-main flex-grow flex flex-col justify-center">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
            <div className="max-w-xl">
              <span className="badge-outline mb-6">RESOURCES</span>
              <h1 className="text-4xl sm:text-5xl font-display font-bold text-ink-green leading-tight mb-6">
                Resources to Help Your Institute <span className="text-gradient-gold">Grow</span>
              </h1>
              <p className="text-lg text-ink-green/70 font-body mb-8 leading-relaxed">
                Practical guides, tips and insights to help coaching institutes
                streamline operations and deliver better learning experiences.
              </p>

              {/* Search Bar */}
              <div className="relative max-w-md">
                <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                  <Search className="h-5 w-5 text-ink-green/40" />
                </div>
                <input
                  type="text"
                  placeholder="Search resources..."
                  className="block w-full pl-11 pr-4 py-3.5 bg-white border border-paper rounded-xl text-ink-green font-body placeholder:text-ink-green/40 focus:outline-none focus:ring-2 focus:ring-chalk-teal/50 transition-all shadow-sm"
                />
              </div>
            </div>

            {/* Illustration Image */}
            <div className="relative flex justify-center lg:justify-center lg:-translate-x-8">
              <div className="w-full max-w-xl lg:scale-110 transition-transform">
                <Image
                  src="/ResourcesPage-Photoroom.png"
                  alt="Resources Illustration"
                  width={700}
                  height={600}
                  className="w-full h-auto object-contain"
                  priority
                />
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* 2. Categories Grid */}
      <section className="pb-20">
        <div className="container-main">
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
            {RESOURCE_CATEGORIES.map((category) => (
              <ResourceCategoryCard key={category.title} {...category} />
            ))}
          </div>
        </div>
      </section>

      {/* 3. Latest Resources */}
      <section className="py-20 bg-white border-y border-paper">
        <div className="container-main">
          <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4 mb-10">
            <h2 className="text-3xl font-display font-bold text-ink-green">
              Latest Resources
            </h2>
            <button className="flex items-center gap-2 text-ink-green font-bold text-sm hover:text-chalk-teal transition-colors">
              View All Resources
              <ArrowRight className="w-4 h-4" />
            </button>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {LATEST_RESOURCES.map((resource) => (
              <ResourceArticleCard key={resource.id} {...resource} />
            ))}
          </div>
        </div>
      </section>

      {/* 4. Popular Topics */}
      <section className="py-20">
        <div className="container-main text-center">
          <h2 className="text-2xl font-display font-bold text-ink-green mb-8">
            Popular Topics
          </h2>
          <div className="flex flex-wrap justify-center gap-3 max-w-4xl mx-auto">
            {POPULAR_TOPICS.map((topic) => (
              <button
                key={topic}
                className="px-6 py-2.5 rounded-full border border-paper bg-white text-ink-green font-body text-sm hover:border-chalk-teal hover:text-chalk-teal transition-colors shadow-sm"
              >
                {topic}
              </button>
            ))}
          </div>
        </div>
      </section>

      {/* 5. Newsletter Banner */}
      <section className="pb-20">
        <div className="container-main">
          <div className="bg-paper rounded-3xl p-8 lg:p-12 relative overflow-hidden flex flex-col md:flex-row items-center gap-8 md:gap-12">
            {/* Newsletter Illustration */}
            <div className="w-40 h-40 shrink-0 flex items-center justify-center">
              <Image
                src="/mail-icon.png"
                alt="Subscribe Newsletter"
                width={160}
                height={160}
                className="w-full h-full object-contain mix-blend-multiply"
              />
            </div>

            <div className="flex-1 text-center md:text-left">
              <h2 className="text-2xl font-display font-bold text-ink-green mb-3">
                Stay Updated with EdTech Insights
              </h2>
              <p className="text-ink-green/70 font-body mb-6 max-w-md mx-auto md:mx-0">
                Subscribe to our newsletter and get the latest tips, guides and
                updates delivered to your inbox.
              </p>
            </div>

            <div className="w-full md:w-auto max-w-md shrink-0">
              <form className="flex gap-2">
                <input
                  type="email"
                  placeholder="Enter your email address"
                  className="flex-1 min-w-[200px] px-4 py-3 rounded-xl border border-white/20 bg-white text-ink-green font-body placeholder:text-ink-green/40 focus:outline-none focus:border-chalk-teal shadow-sm"
                  required
                />
                <Button variant="primary" type="submit">
                  Subscribe
                </Button>
              </form>
              <div className="flex items-center gap-2 mt-3 text-ink-green/60 text-xs font-body justify-center md:justify-start">
                <CheckCircle2 className="w-3.5 h-3.5" />
                <span>No spam. Unsubscribe anytime.</span>
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}
